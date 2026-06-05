# GT2N BSPDN physical/signoff grid insertion for the OpenROAD compatibility flow.
#
# Purpose
# -------
# OpenROAD/TritonRoute currently has practical limitations with lower/backside
# pin access and direct BPR/backside routing.  The BSPDN proxy flow therefore
# uses two views of the same design:
#
#   1. routing view: a stable frontside-only OpenROAD view that can complete
#      placement, signal routing, and stream-out without asking TritonRoute to
#      route BPR/BM layers.
#   2. physical/signoff view: the streamed GDS plus deterministic backside PG
#      geometry on real GT2N BPR/BM/BRDL/BV layers.
#
# This script implements step 2.  It adds a structured backside VDD/VSS mesh to
# the routed GDS.  It is intentionally deterministic: rails, stripes, labels,
# and via cuts are generated from the top-cell/core bounding box and a small set
# of pitch/width parameters.  TritonRoute is not involved.
#
# Invocation example:
#   klayout -b -r add_bspdn_signoff_grid.rb \
#     -rd in_gds=6_final.gds \
#     -rd out_gds=6_final_bspdn_physical.gds \
#     -rd report=6_bspdn_physical_grid.rpt \
#     -rd topcell=aes \
#     -rd core_margin_um=5.04
#
# Notes/limits
# ------------
# - This is a compatibility abstraction, not native OpenROAD BSPDN support.
# - The script creates real GT2N layers in GDS so KLayout DRC/LVS decks can use
#   the normal BM*/BV*/BPR connectivity chain.
# - The default BPR rail pitch is the GT2N row/site vertical pitch used by the
#   6T cells.  If a design uses a non-default floorplan origin or row pattern,
#   pass explicit core_margin_um/offset knobs.

include RBA


def rd_value(name, default = nil)
  gname = "$#{name}"
  if global_variables.include?(gname.to_sym)
    value = eval(gname)
    return value unless value.nil? || value.to_s.empty?
  end
  default
end


def rd_float(name, default)
  rd_value(name, default).to_f
end


def dbu_i(um, dbu)
  (um.to_f / dbu).round
end


def add_box(cell, layer, x1, y1, x2, y2)
  return if x2 <= x1 || y2 <= y1
  cell.shapes(layer).insert(Box.new(x1, y1, x2, y2))
end


def add_label(cell, layer, text, x, y)
  cell.shapes(layer).insert(Text.new(text, Trans.new(x, y)))
end


def add_stripes(cell:, layer:, label_layer:, orientation:, xmin:, xmax:, ymin:, ymax:,
                width_um:, pitch_um:, offset_um:, dbu:, first_net:, label_every:)
  width = dbu_i(width_um, dbu)
  half = [width / 2, 1].max
  pitch = dbu_i(pitch_um, dbu)
  offset = dbu_i(offset_um, dbu)
  net_for = lambda do |idx|
    if first_net.upcase == "VDD"
      idx.even? ? "VDD" : "VSS"
    else
      idx.even? ? "VSS" : "VDD"
    end
  end

  stripes = []
  pos = (orientation == :horizontal ? ymin : xmin) + offset
  limit = orientation == :horizontal ? ymax : xmax
  idx = 0
  while pos <= limit
    net = net_for.call(idx)
    if orientation == :horizontal
      add_box(cell, layer, xmin, pos - half, xmax, pos + half)
      add_label(cell, label_layer, net, xmin + dbu_i(0.2, dbu), pos) if idx % label_every == 0
    else
      add_box(cell, layer, pos - half, ymin, pos + half, ymax)
      add_label(cell, label_layer, net, pos, ymin + dbu_i(0.2, dbu)) if idx % label_every == 0
    end
    stripes << { pos: pos, net: net }
    pos += pitch
    idx += 1
  end
  stripes
end


def add_via_array(cell:, layer:, verticals:, horizontals:, via_x_um:, via_y_um:, dbu:)
  hx = [dbu_i(via_x_um, dbu) / 2, 1].max
  hy = [dbu_i(via_y_um, dbu) / 2, 1].max
  count = 0
  verticals.each do |v|
    horizontals.each do |h|
      next unless v[:net] == h[:net]
      add_box(cell, layer, v[:pos] - hx, h[:pos] - hy, v[:pos] + hx, h[:pos] + hy)
      count += 1
    end
  end
  count
end

in_gds = rd_value("in_gds", rd_value("input", nil))
out_gds = rd_value("out_gds", rd_value("output_gds", nil))
report_path = rd_value("report", nil)
topcell_name = rd_value("topcell", nil)
raise "Missing -rd in_gds=<input.gds>" if in_gds.nil? || in_gds.to_s.empty?
raise "Missing -rd out_gds=<output.gds>" if out_gds.nil? || out_gds.to_s.empty?

layout = Layout.new
layout.read(in_gds)
dbu = layout.dbu

top = nil
if topcell_name && !topcell_name.to_s.empty?
  top = layout.cell(topcell_name)
  raise "Top cell '#{topcell_name}' not found in #{in_gds}" if top.nil?
else
  tops = layout.top_cells
  raise "No top cells found in #{in_gds}" if tops.empty?
  top = tops.first
end

# GT2N physical layers/datatype mapping.
layers = {
  bpr:  layout.layer(8, 0),    bpr_txt:  layout.layer(8, 20),
  bv0:  layout.layer(910, 0),
  bm1:  layout.layer(920, 0),  bm1_txt:  layout.layer(920, 20),
  bv1:  layout.layer(930, 0),
  bm2:  layout.layer(940, 0),  bm2_txt:  layout.layer(940, 20),
  bv2:  layout.layer(950, 0),
  bm3:  layout.layer(960, 0),  bm3_txt:  layout.layer(960, 20),
  bv3:  layout.layer(970, 0),
  bm4:  layout.layer(980, 0),  bm4_txt:  layout.layer(980, 20),
  bv4:  layout.layer(990, 0),
  brdl: layout.layer(1000, 0), brdl_txt: layout.layer(1000, 20)
}

bbox = top.bbox
margin = dbu_i(rd_float("core_margin_um", 5.04), dbu)
xmin = bbox.left + margin
xmax = bbox.right - margin
ymin = bbox.bottom + margin
ymax = bbox.top - margin
raise "Core bbox collapsed after margin. bbox=#{bbox.to_s} margin=#{margin}" if xmax <= xmin || ymax <= ymin

first_net = rd_value("first_net", "VSS")
label_every = rd_value("label_every", 32).to_i

# Defaults are intentionally conservative and legal relative to the GT2N tech LEF.
bpr = add_stripes(cell: top, layer: layers[:bpr], label_layer: layers[:bpr_txt],
                  orientation: :horizontal, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                  width_um: rd_float("bpr_width_um", 0.032),
                  pitch_um: rd_float("bpr_pitch_um", 0.144),
                  offset_um: rd_float("bpr_offset_um", 0.0), dbu: dbu,
                  first_net: first_net, label_every: label_every)

bm1 = add_stripes(cell: top, layer: layers[:bm1], label_layer: layers[:bm1_txt],
                  orientation: :vertical, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                  width_um: rd_float("bm1_width_um", 0.056),
                  pitch_um: rd_float("bm1_pitch_um", 0.672),
                  offset_um: rd_float("bm1_offset_um", 0.0), dbu: dbu,
                  first_net: first_net, label_every: label_every)

bm2 = add_stripes(cell: top, layer: layers[:bm2], label_layer: layers[:bm2_txt],
                  orientation: :horizontal, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                  width_um: rd_float("bm2_width_um", 0.056),
                  pitch_um: rd_float("bm2_pitch_um", 0.672),
                  offset_um: rd_float("bm2_offset_um", 0.0), dbu: dbu,
                  first_net: first_net, label_every: label_every)

bm3 = add_stripes(cell: top, layer: layers[:bm3], label_layer: layers[:bm3_txt],
                  orientation: :vertical, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                  width_um: rd_float("bm3_width_um", 0.36),
                  pitch_um: rd_float("bm3_pitch_um", 5.76),
                  offset_um: rd_float("bm3_offset_um", 0.0), dbu: dbu,
                  first_net: first_net, label_every: [label_every / 4, 1].max)

bm4 = add_stripes(cell: top, layer: layers[:bm4], label_layer: layers[:bm4_txt],
                  orientation: :horizontal, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                  width_um: rd_float("bm4_width_um", 0.36),
                  pitch_um: rd_float("bm4_pitch_um", 5.76),
                  offset_um: rd_float("bm4_offset_um", 0.0), dbu: dbu,
                  first_net: first_net, label_every: [label_every / 4, 1].max)

brdl = add_stripes(cell: top, layer: layers[:brdl], label_layer: layers[:brdl_txt],
                   orientation: :vertical, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
                   width_um: rd_float("brdl_width_um", 1.60),
                   pitch_um: rd_float("brdl_pitch_um", 12.80),
                   offset_um: rd_float("brdl_offset_um", 0.0), dbu: dbu,
                   first_net: first_net, label_every: 1)

counts = {}
counts[:bv0] = add_via_array(cell: top, layer: layers[:bv0], verticals: bm1, horizontals: bpr,
                             via_x_um: rd_float("bv0_x_um", 0.020),
                             via_y_um: rd_float("bv0_y_um", 0.020), dbu: dbu)
counts[:bv1] = add_via_array(cell: top, layer: layers[:bv1], verticals: bm1, horizontals: bm2,
                             via_x_um: rd_float("bv1_x_um", 0.028),
                             via_y_um: rd_float("bv1_y_um", 0.028), dbu: dbu)
counts[:bv2] = add_via_array(cell: top, layer: layers[:bv2], verticals: bm3, horizontals: bm2,
                             via_x_um: rd_float("bv2_x_um", 0.028),
                             via_y_um: rd_float("bv2_y_um", 0.028), dbu: dbu)
counts[:bv3] = add_via_array(cell: top, layer: layers[:bv3], verticals: bm3, horizontals: bm4,
                             via_x_um: rd_float("bv3_x_um", 0.090),
                             via_y_um: rd_float("bv3_y_um", 0.090), dbu: dbu)
counts[:bv4] = add_via_array(cell: top, layer: layers[:bv4], verticals: brdl, horizontals: bm4,
                             via_x_um: rd_float("bv4_x_um", 0.120),
                             via_y_um: rd_float("bv4_y_um", 0.120), dbu: dbu)

layout.write(out_gds)
summary = [
  "GT2N BSPDN proxy physical/signoff grid insertion",
  "input_gds: #{in_gds}",
  "output_gds: #{out_gds}",
  "topcell: #{top.name}",
  "dbu_um: #{dbu}",
  "bbox_dbu: #{bbox.to_s}",
  "core_window_dbu: (#{xmin}, #{ymin}) (#{xmax}, #{ymax})",
  "bpr_rails: #{bpr.length}",
  "bm1_stripes: #{bm1.length}",
  "bm2_stripes: #{bm2.length}",
  "bm3_stripes: #{bm3.length}",
  "bm4_stripes: #{bm4.length}",
  "brdl_stripes: #{brdl.length}",
  "bv0_cuts: #{counts[:bv0]}",
  "bv1_cuts: #{counts[:bv1]}",
  "bv2_cuts: #{counts[:bv2]}",
  "bv3_cuts: #{counts[:bv3]}",
  "bv4_cuts: #{counts[:bv4]}"
].join("\n") + "\n"
puts summary
File.write(report_path, summary) if report_path && !report_path.to_s.empty?
