# A11 Reproduction Plan v1.00

Source: `Original_EA/A11/A_11_MACross_MT5_v107.mq5`

## Source-defined behavior
- Chart timeframe: `PERIOD_CURRENT`; the source does not prescribe a fixed symbol or timeframe.
- Fast MA: EMA 100 by default.
- Slow MA: EMA 200 by default.
- Signal evaluation: once per new chart bar after indicator buffers are copied.
- BUY: previous closed bar close > fastMA[1], fastMA[2] <= slowMA[2], fastMA[1] > slowMA[1].
- SELL: previous closed bar close < fastMA[1], fastMA[2] >= slowMA[2], fastMA[1] < slowMA[1].
- MTF MA filter: disabled by default.
- TP/SL: 0 by default.
- Fast-MA exit: disabled by default.
- Opposite signal: opposite owned position is requested closed before a new same-direction-presence check/open attempt.
- Position ownership: symbol + MagicNumber 889.
- New-bar state: prevTime starts at zero, so the first tick processed after initialization is treated as a new bar.
- Equity guard: processing stops while equity < minEquity (default 100).
- Gold/XAU lot: 0.01 before broker volume normalization; non-gold uses equity/10000 capped by maxLotSize.
- No source-defined test symbol, fixed timeframe, or historical date range was found.

## Reproduction rule
Do not choose a special A11 symbol/timeframe/date and present it as an original-author baseline. For cross-alpha regression, use the existing laboratory common baseline as a clearly labelled research baseline:
- XAUUSD_DUKA
- M15
- 2026-08-16 through 2026-08-29
- real ticks
- initial deposit JPY 100000
- original A11 default inputs

The original EA must be run first under this common baseline. Its observed signal/order/position lifecycle becomes the A11 parity target.

## NoOrders boundary
The reproduction version must not call CTrade, OrderSend, or OrderCheck. It must preserve:
1. CopyBuffer-before-new-bar ordering.
2. first-tick/new-bar behavior.
3. exact [1]/[2] MA crossover comparisons.
4. close-vs-fast-MA condition.
5. optional MTF filter implementation when enabled.
6. opposite-position close-before-open ordering.
7. symbol+magic ownership semantics.
8. default TP/SL and optional fast-MA exit behavior.
9. executable BUY/SELL side price semantics when virtualizing fills.

Status: SOURCE_ANALYSIS_COMPLETE / ORIGINAL_BASELINE_NOT_YET_OBSERVED.
