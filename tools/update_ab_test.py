#!/usr/bin/env python3
"""Unit tests for update_ab.py (the A/B table generator)."""

import os
import tempfile
import unittest

import update_ab


class MinPeriodTest(unittest.TestCase):
    def test_fmax_clock_key_ps(self):
        m = {"globalroute__timing__fmax__clock:core_clock": 2.0e9}
        self.assertAlmostEqual(update_ab.min_period_ps(m, "globalroute"), 500.0)

    def test_fmax_fallback_key_ps(self):
        m = {"cts__timing__fmax": 4.0e9}
        self.assertAlmostEqual(update_ab.min_period_ps(m, "cts"), 250.0)

    def test_missing_returns_none(self):
        self.assertIsNone(update_ab.min_period_ps({}, "floorplan"))

    def test_nonpositive_returns_none(self):
        self.assertIsNone(update_ab.min_period_ps({"cts__timing__fmax": 0}, "cts"))


class AreaUtilTest(unittest.TestCase):
    def setUp(self):
        self.m = {
            "globalroute__design__instance__area": 19.97,
            "globalroute__design__instance__utilization": 0.311,
            "finish__design__instance__area": 56.99,
            "finish__design__die__area": 80.59,
            "finish__design__instance__utilization": 0.923,
        }

    def test_area_uses_finish_stage(self):
        self.assertAlmostEqual(update_ab.area(self.m, "gt2n", "instance"), 56.99)
        self.assertAlmostEqual(update_ab.area(self.m, "asap7", "die"), 80.59)

    def test_utilization_uses_finish_stage(self):
        self.assertAlmostEqual(update_ab.utilization(self.m, "gt2n"), 0.923)
        self.assertAlmostEqual(update_ab.utilization(self.m, "asap7"), 0.923)

    def test_missing_returns_none(self):
        self.assertIsNone(update_ab.area({}, "gt2n", "die"))
        self.assertIsNone(update_ab.utilization({}, "asap7"))


class NumTest(unittest.TestCase):
    def test_parses_string_values(self):
        self.assertEqual(
            update_ab.num({"CORE_UTILIZATION": "25"}, "CORE_UTILIZATION"), 25.0
        )
        self.assertEqual(
            update_ab.num({"PLACE_DENSITY": "0.35"}, "PLACE_DENSITY"), 0.35
        )

    def test_missing_or_bad_returns_none(self):
        self.assertIsNone(update_ab.num({}, "CORE_UTILIZATION"))
        self.assertIsNone(update_ab.num({"CORE_UTILIZATION": "x"}, "CORE_UTILIZATION"))


class CellTest(unittest.TestCase):
    def test_none(self):
        self.assertEqual(update_ab.cell(None), "n/a")

    def test_skipped(self):
        self.assertEqual(update_ab.cell(500.0, skipped=True), "_skipped_")

    def test_formats(self):
        self.assertEqual(update_ab.cell(19.97), "19.970")
        self.assertEqual(update_ab.cell(500.0, "{:.1f}"), "500.0")
        self.assertEqual(update_ab.cell(25.0, "{:.0f}"), "25")


class RenderTest(unittest.TestCase):
    def setUp(self):
        self.gt2n_m = {
            "floorplan__timing__fmax__clock:core_clock": 3.48e9,
            "globalroute__timing__fmax__clock:core_clock": 2.0e9,
            "globalroute__design__instance__area": 19.97,
            "globalroute__design__die__area": 83.46,
            "globalroute__design__instance__utilization": 0.311,
        }
        self.gt2n_m["finish__timing__fmax__clock:core_clock"] = 2.54e9
        self.gt2n_m["finish__design__instance__area"] = 64.20
        self.gt2n_m["finish__design__die__area"] = 83.46
        self.gt2n_m["finish__design__instance__utilization"] = 1.0
        self.asap7_m = {
            "finish__timing__fmax__clock:core_clock": 2.56e9,
            "finish__design__instance__area": 56.99,
            "finish__design__die__area": 80.59,
            "finish__design__instance__utilization": 0.923,
        }
        self.gt2n_a = {"CORE_UTILIZATION": "25", "PLACE_DENSITY": "0.35"}
        self.asap7_a = {"CORE_UTILIZATION": "65", "PLACE_DENSITY": "0.35"}
        self.block = update_ab.render(
            self.gt2n_m, self.asap7_m, self.gt2n_a, self.asap7_a
        )

    def test_markers_present(self):
        self.assertIn(update_ab.START, self.block)
        self.assertIn(update_ab.END, self.block)

    def test_period_in_ps(self):
        gr = [l for l in self.block.splitlines() if "Global route" in l][0]
        self.assertIn("500.0", gr)  # 1e12 / 2.0e9

    def test_detailed_route_shown_for_both(self):
        line = [l for l in self.block.splitlines() if "Detailed route" in l][0]
        cells = [c.strip() for c in line.strip("|").split("|")]
        self.assertNotIn("_skipped_", (cells[1], cells[2]))
        self.assertNotIn("n/a", (cells[1], cells[2]))

    def test_density_and_utilization_rows(self):
        self.assertIn("| Core utilization target (%) | 25 | 65 |", self.block)
        self.assertIn("| Placement density target | 0.35 | 0.35 |", self.block)
        # achieved utilization now read from the finish stage for both
        self.assertIn("| Achieved utilization | 1.000 | 0.923 |", self.block)

    def test_area_rows(self):
        self.assertIn("| Cell area (um^2) | 64.200 | 56.990 |", self.block)
        self.assertIn("| Die area (um^2) | 83.460 | 80.590 |", self.block)


class SpliceTest(unittest.TestCase):
    def _write(self, text):
        fd, path = tempfile.mkstemp(suffix=".md")
        os.close(fd)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        return path

    def test_replaces_between_markers(self):
        path = self._write(
            "intro\n{}\nOLD\n{}\noutro\n".format(update_ab.START, update_ab.END)
        )
        update_ab.splice(path, update_ab.START + "\nNEW\n" + update_ab.END)
        with open(path, encoding="utf-8") as fh:
            out = fh.read()
        self.assertIn("NEW", out)
        self.assertNotIn("OLD", out)
        self.assertIn("intro", out)
        self.assertIn("outro", out)

    def test_appends_when_no_markers(self):
        path = self._write("just intro\n")
        update_ab.splice(path, update_ab.START + "\nX\n" + update_ab.END)
        with open(path, encoding="utf-8") as fh:
            out = fh.read()
        self.assertIn("just intro", out)
        self.assertIn(update_ab.START, out)


class LoadTest(unittest.TestCase):
    def test_load_metrics_and_args_from_workspace(self):
        ws = tempfile.mkdtemp()
        base = os.path.join(ws, "bazel-out", "k8-fastbuild", "bin", "orfs")
        logs = os.path.join(base, "logs", "gt2n", update_ab.DESIGN, "base")
        results = os.path.join(base, "results", "gt2n", update_ab.DESIGN, "base")
        os.makedirs(logs)
        os.makedirs(results)
        with open(os.path.join(logs, "5_1_grt.json"), "w") as fh:
            fh.write('{"globalroute__timing__fmax": 2.0e9}')
        with open(os.path.join(results, "2_floorplan.args.json"), "w") as fh:
            fh.write('{"CORE_UTILIZATION": "25", "PLACE_DENSITY": "0.35"}')
        old = os.environ.get("BUILD_WORKSPACE_DIRECTORY")
        os.environ["BUILD_WORKSPACE_DIRECTORY"] = ws
        try:
            m = update_ab.load_metrics("gt2n")
            a = update_ab.load_args("gt2n")
        finally:
            if old is None:
                os.environ.pop("BUILD_WORKSPACE_DIRECTORY", None)
            else:
                os.environ["BUILD_WORKSPACE_DIRECTORY"] = old
        self.assertIn("globalroute__timing__fmax", m)
        self.assertEqual(a.get("CORE_UTILIZATION"), "25")


if __name__ == "__main__":
    unittest.main()
