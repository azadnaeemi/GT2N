// Functional models. Power pins are implicit, as in synthesis Liberty.
module gt2_6t_and4_w13_lvt (A, B, C, D, Y);
  input A, B, C, D;
  output Y;
  assign Y = (A & B & C & D);
endmodule

module gt2_6t_and5_w13_lvt (A, B, C, D, E, Y);
  input A, B, C, D, E;
  output Y;
  assign Y = (A & B & C & D & E);
endmodule

module gt2_6t_ao221_w13_lvt (A1, A2, B1, B2, C, Y);
  input A1, A2, B1, B2, C;
  output Y;
  assign Y = ((A1 & A2) | (B1 & B2) | C);
endmodule

module gt2_6t_ao222_w13_lvt (A1, A2, B1, B2, C1, C2, Y);
  input A1, A2, B1, B2, C1, C2;
  output Y;
  assign Y = ((A1 & A2) | (B1 & B2) | (C1 & C2));
endmodule

module gt2_6t_aoi221_w13_lvt (A1, A2, B1, B2, C, Y);
  input A1, A2, B1, B2, C;
  output Y;
  assign Y = !((A1 & A2) | (B1 & B2) | C);
endmodule

module gt2_6t_aoi222_w13_lvt (A1, A2, B1, B2, C1, C2, Y);
  input A1, A2, B1, B2, C1, C2;
  output Y;
  assign Y = !((A1 & A2) | (B1 & B2) | (C1 & C2));
endmodule

module gt2_6t_maj3_w13_lvt (A, B, C, Y);
  input A, B, C;
  output Y;
  assign Y = ((A & B) | (A & C) | (B & C));
endmodule

module gt2_6t_maji3_w13_lvt (A, B, C, Y);
  input A, B, C;
  output Y;
  assign Y = !((A & B) | (A & C) | (B & C));
endmodule

module gt2_6t_nand4_w13_lvt (A, B, C, D, Y);
  input A, B, C, D;
  output Y;
  assign Y = !(A & B & C & D);
endmodule

module gt2_6t_nand5_w13_lvt (A, B, C, D, E, Y);
  input A, B, C, D, E;
  output Y;
  assign Y = !(A & B & C & D & E);
endmodule

module gt2_6t_nor4_w13_lvt (A, B, C, D, Y);
  input A, B, C, D;
  output Y;
  assign Y = !(A | B | C | D);
endmodule

module gt2_6t_nor5_w13_lvt (A, B, C, D, E, Y);
  input A, B, C, D, E;
  output Y;
  assign Y = !(A | B | C | D | E);
endmodule

module gt2_6t_oa221_w13_lvt (A1, A2, B1, B2, C, Y);
  input A1, A2, B1, B2, C;
  output Y;
  assign Y = ((A1 | A2) & (B1 | B2) & C);
endmodule

module gt2_6t_oa222_w13_lvt (A1, A2, B1, B2, C1, C2, Y);
  input A1, A2, B1, B2, C1, C2;
  output Y;
  assign Y = ((A1 | A2) & (B1 | B2) & (C1 | C2));
endmodule

module gt2_6t_oai221_w13_lvt (A1, A2, B1, B2, C, Y);
  input A1, A2, B1, B2, C;
  output Y;
  assign Y = !((A1 | A2) & (B1 | B2) & C);
endmodule

module gt2_6t_oai222_w13_lvt (A1, A2, B1, B2, C1, C2, Y);
  input A1, A2, B1, B2, C1, C2;
  output Y;
  assign Y = !((A1 | A2) & (B1 | B2) & (C1 | C2));
endmodule

module gt2_6t_or4_w13_lvt (A, B, C, D, Y);
  input A, B, C, D;
  output Y;
  assign Y = (A | B | C | D);
endmodule

module gt2_6t_or5_w13_lvt (A, B, C, D, E, Y);
  input A, B, C, D, E;
  output Y;
  assign Y = (A | B | C | D | E);
endmodule
