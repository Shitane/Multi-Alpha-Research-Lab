# Legacy Logic Demo Forward History

Source workbook: `3(20261006-143708).xlsx`

Purpose: preserve the completed forward-test history of the legacy O01 reproduction logic before replacing the two legacy-logic demo environments with the new comparison setup:

- Original EA
- Multi-Alpha Builder: `MA_LD2A_O01BuilderBridge_v3_33.mq5`

## Source report

- Broker/server: TitanFX-MT5-Demo
- Account currency: JPY
- Account type: demo / Hedge
- Symbol: XAUUSD-m
- Report generated: 2026-10-06 23:29
- Closed positions: 1,030
- Total profit: 27,958 JPY
- Gross profit: 57,708 JPY
- Gross loss: -29,750 JPY
- Profit factor: 1.939765
- Recovery factor: 6.368565
- Sharpe ratio: 0.130213
- Max balance drawdown: 4,390 JPY (5.95%)
- Winning positions: 716 (69.51%)
- Losing positions: 314 (30.49%)

## Files

`legacy_logic_demo_daily_summary_2026-10-06.csv` is derived from the Position History section of the source workbook. It aggregates all 1,030 closed positions by entry date. The daily `profit_jpy` values sum to 27,958 JPY, matching the report total.

The original XLSX should be retained locally as the authoritative raw MT5 report. This GitHub dataset is intended as a durable comparison reference for legacy reproduction vs Original EA vs Multi-Alpha Builder.
