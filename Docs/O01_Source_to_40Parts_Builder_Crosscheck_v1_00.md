# O01 原典 → 40 Parts → Builder 照合表 v1.00

## 1. 目的と基準
基準EA:
`Parity_Tests/MultiAlpha/MA_LD2A_SlotBasicInfoFix_v3_11.mq5`

O01原典:
`O01_GSG_RSI30_Monolithic_Module_v1_00.mqh`

現行40 Parts:
`Include/Builder/MultiAlpha_Builder_FreeSlot_Panel_v1_26.mqh`

現行Part定義:
- `Include/Builder/MultiAlpha_Builder_Part_Registry_v1_01.mqh`
- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_00.mqh`

現行Interpreter:
`Modules/Builder/MultiAlpha_Builder_Interpreter_v1_01.mqh`

判定:
- **一致**: 現行Part/実行意味で原典を表現できる
- **部分一致**: Part/値はあるが条件・状態・役割・実行意味が不足
- **不足**: 原典意味を表現する汎用Part/状態/実行経路がない
- **Builder外**: Strategy PartではなくHost/Execution/Safety層で扱うべき

> 重要: 過去のParity PASSは、そのテストが明示した限定スコープでは有効。しかし「40 Parts保存定義だけで原典O01全体を再構成できる」ことまでは証明していない。

## 2. 最重要構造差

|項目|O01原典/正規設計|現行Builder|判定|対応|
|---|---|---|---|---|
|Role構造|ENTRY → GRID → MANAGE → EXIT|FreeSlot v1_26は4 Role。一方 Part Schema v1_00 は ENTRY/MANAGE/EXIT の3 Role|**不足**|Schemaを4 Role正規順へ統一。旧MANAGE内Grid PartsをGRIDへ移す|
|40 Parts|各Role 40 Parts|FreeSlot v1_26は4×40|一致|維持|
|AND/OR|BUY branch と SELL branch 等、論理グループ意味が必要|Interpreter v1_01は括弧/優先順位なしの左から逐次評価|**不足・重大**|グループ/括弧/branch表現を追加するか、同等の決定木構造を定義|
|評価順|Emergency → side manage → lock → new-cycle gates → entry|単純なPart列だけでは全体制御順を表現できない|**部分一致**|Strategy Dispatcher側のphase順として固定し、Part式と分離|
|状態保持|Trailing peak/stop/count、last order bar、emergency lock等|一部Evaluatorには状態あり。40 Parts定義だけでは状態所有者が不明確|**部分一致**|汎用Runtime Stateとして明文化/実装|

### 重大なInterpreter注意
現行InterpreterはANDをORより優先しない。例えば現行ENTRY seed:
`BUY条件 ... BUY OR SELL条件 ... SELL`
は、通常期待する
`(BUY条件...) OR (SELL条件...)`
として保証されない。

同様にGRID seed末尾の
`... AND ADD_BUY OR ADD_SELL`
もside branchの意味を40 Parts式だけでは安全に表せない。

**O01-R2で最優先修正対象。**

## 3. ENTRY照合

|#|原典O01|原典値/意味|現行Part/経路|判定|O01-R2対応|
|---|---|---|---|---|---|
|E01|New Cycles|InpNewCycles=true|CYCLE_NEW|一致|維持|
|E02|Emergency Lock OFF|lock中は新規不可|Registryに EMERGENCY_UNLOCKED、Generic seedには未配置|部分一致|ENTRY gateへ明示|
|E03|時間帯|IsNewCycleTimeAllowed()|Registry TIME_ALLOWEDあり、Schema ENTRYでは許可されていない。Generic seedにも未配置|不足|汎用TIME_ALLOWEDをENTRYへ|
|E04|News new-cycle block|NewsBlocksNewCycle()|Registry NEWS_CLEARあり、Schema/seed不足|不足|汎用NEWS_CLEAR|
|E05|Spread|SpreadOK()|Registry SPREAD_OKあり、Schema/seed不足|不足|汎用SPREAD_OK|
|E06|ATR filter 1|period 15/current TF, 0–10000 pt|Schema ATR_RANGEあり、Generic seedはFILTERS_OKに集約|部分一致|ATR_RANGE #1として明示|
|E07|ATR filter 2|period 15/config TF, 0–10000 pt|ATR_RANGEで表現可能|部分一致|ATR_RANGE #2として明示|
|E08|RSI|period 8, PRICE_CLOSE|RSI_THRESHOLD|一致|TF/PRICEもRuntimeで厳密反映|
|E09|BUY閾値|RSI < 30|RSI_THRESHOLD LT 30|一致|維持|
|E10|SELL閾値|RSI > 70|RSI_THRESHOLD GT 70|一致|維持|
|E11|BUY既存数|BUY count == 0|SIDE_COUNT BUY EQ 0|一致|維持|
|E12|SELL既存数|SELL count == 0|SIDE_COUNT SELL EQ 0|一致|維持|
|E13|方向許可|InpTradeBuy / InpTradeSell|明示Partなし|不足|TRADE_SIDE_ENABLED等の汎用Part候補|
|E14|Initial lot|0.01|SchemaにINITIAL_LOT記述はあるがRegistry/seed ENTRYにない|部分一致|注文Action parameterかPosition sizing層へ|
|E15|one order/bar initial|InitialにもAlreadyOrderedThisBar適用|ONE_ORDER_PER_BARはGrid寄りのみ|不足|ENTRYにも適用可能な汎用gate化|
|E16|BUY/SELL action|OpenInitial BUY/SELL|BUY / SELL|部分一致|Actionと条件をbranch単位で結合|
|E17|BUY/SELL同tick評価|BUY判定後SELL判定も独立if|現行単一bool式では意味が曖昧|不足|方向別branch outputを保持|

### ENTRY結論
RSI中心の基本判定は既存Parityで強く確認済みだが、**原典ENTRYの完全gate列（Emergency/Time/News/Spread/ATR/TradeSide/one-bar）を40 Parts保存定義だけで表現する状態にはまだない。**

## 4. GRID照合

|#|原典O01|原典値/意味|現行Part/経路|判定|O01-R2対応|
|---|---|---|---|---|---|
|G01|既存sideあり|count > 0|SIDE_COUNT|一致|GRID roleへ正式許可|
|G02|max orders|10/side|MAX_ORDERS 10|一致|維持|
|G03|DD Grid Pause|DD >=12%なら追加停止|Generic seedなし|不足|Safety state inputとしてGRID gate化|
|G04|Trailing中Grid Pause|default true|TRAILING_PAUSE|一致|Runtime state接続確認|
|G05|時間外Grid|AllowGridOutsideTime=true|Generic seedなし|不足|ALLOW_GRID_OUTSIDE_TIME + TIME state|
|G06|News grid block|NewsBlocksGrid()|FILTERS_OKへ暗黙化の可能性|不足|NEWS_GRID_CLEARを明示|
|G07|Spread|SpreadOK()|FILTERS_OKへ暗黙化|不足|SPREAD_OKをGRIDでも利用|
|G08|one order/bar|true|ONE_ORDER_PER_BAR|一致|再起動時state復元要確認|
|G09|基準価格|NewestPositionOpenPrice|LAST_PRICEはRegistryにあるがseed未配置|部分一致|明示/Runtime context|
|G10|固定距離|next order <3 → 200pt|FIXED_DISTANCE 200|一致|DYNAMICとの選択意味を実装|
|G11|動的開始|order 3|DYNAMIC_DISTANCE start=3|一致|維持|
|G12|動的開始距離|300pt|START_POINTS=300|一致|維持|
|G13|距離倍率|1.20|MULT=1.20|一致|維持|
|G14|BUY追加方向|ask <= last - distance|Evaluatorに実装、Part列では方向条件が不明確|部分一致|汎用DISTANCE_REACHED side-aware|
|G15|SELL追加方向|bid >= last + distance|同上|部分一致|同上|
|G16|次Lot|latest lot ×1.50|LOT_MULTIPLIER 1.50|一致|latest-lot入力を保証|
|G17|max single lot|5.00|MAX_LOT 5.00|一致|維持|
|G18|lot normalization|broker min/max/step, nearest step|40 Parts seedなし|不足/Execution|汎用lot normalization層|
|G19|max total lots/side|1.20|MAX_TOTAL_LOT 1.20|一致|維持|
|G20|ADD BUY/SELL|side別Action|ADD_BUY / ADD_SELL|部分一致|branch構造修正|

### GRID結論
距離・ロット系列はかなり揃っている。一方、**DD12%、News、Spread、時間外許可、last price、方向別distance条件、lot normalization**が40 Parts保存定義として不足/暗黙化している。

## 5. MANAGE照合

原典の `ManageSide()` は「GRIDだけ」ではない。処理順は概ね:
1. side count / weighted average
2. Virtual SL
3. Single/Basket Exit mode
4. Trailing or Fixed TP
5. Overlap
6. Grid eligibility / add

新しい4 Role構造では、これを責務分離する必要がある。

|#|原典O01|意味|現行Part/経路|判定|O01-R2対応|
|---|---|---|---|---|---|
|M01|side count|0ならtrail reset|POSITION_COUNT/SIDE_COUNT|部分一致|state reset意味を追加|
|M02|weighted average|side weighted BE|AVG_PRICE|一致|Runtime context保証|
|M03|move points|BUY/SELL方向別|MOVE_POINTS|一致|side-aware計算保証|
|M04|Trailing state|active/peak/stop/count|SINGLE/BASKET trailing + evaluator state|部分一致|状態所有者を汎用化|
|M05|basket構成変更|count変化でtrail reset|Evaluatorに実装|部分一致|Part/state semanticとして固定|
|M06|Overlap|count>=8、oldest loser + newest winner、3%超で2件close|現行40 Partsに無し|**不足**|汎用OVERLAP Parts群追加|
|M07|Overlap実行順|newest winner → oldest loser|無し|不足|Action sequenceとして保持|
|M08|保護優先順|SL/ExitがOverlap/Gridより先|単純式では表現不能|不足|Dispatcher phase/orderで固定|

### MANAGE結論
新4 Roleでは、MANAGEを「状態/ポジション管理・Overlap等」、GRIDを「追加注文判定」、EXITを「決済判定」に分けるのが原典忠実性と再利用性の両方に適する。ただし**原典の評価順は絶対に維持**する。

## 6. EXIT照合

|#|原典O01|原典値/意味|現行Part/経路|判定|O01-R2対応|
|---|---|---|---|---|---|
|X01|Virtual SL|1500pt、profit exit modeと独立|VIRTUAL_SL 1500|一致|EXIT最優先で維持|
|X02|Single exit mode|default TRAILING|seedにSingle trailingあり|一致|mode selectorを明示|
|X03|Basket exit mode|default TRAILING|Basket trailingあり|一致|mode selectorを明示|
|X04|Single fixed TP|110pt|FIXED_TP 110|部分一致|Single/Basket区別が必要|
|X05|Single money TP|optional 15 account currency|Partなし|不足|TP_MONEY汎用Part|
|X06|Basket fixed TP|100pt weighted BE|seedでは110しか明示されない|不足|BASKET_FIXED_TP 100相当を汎用化|
|X07|Single trail|110/60/50/10|SINGLE_TRAILING|一致|維持|
|X08|Basket trail|100/50/50/10|BASKET_TRAILING|一致|維持|
|X09|trail activation|move >= start|Evaluator実装|一致|維持|
|X10|trail step|peak improvement >= step|Evaluator実装|一致|維持|
|X11|trail close|move <= stop|Evaluator実装|一致|維持|
|X12|count change reset|basket composition change時reset|Evaluator実装|一致/状態依存|汎用stateへ|
|X13|close opposite option|default false、SL/TP/Trail後に反対side close可|Partなし|不足|CLOSE_OPPOSITE_AFTER_EXIT汎用option|
|X14|close reason|VSL/TP/Single/Basket等|40 Partsには十分なreason意味なし|部分一致|runtime event metadata化|

## 7. TIME / NEWS / FILTER照合

|項目|原典|現行40 Parts|判定|
|---|---|---|---|
|TimeMode|AUTO_GMT / SERVER_TIME / CUSTOM_GMT|TIME_ALLOWEDのmetadataはあるがseed/schema不足|不足|
|AUTO_GMT default|07:00–11:00 GMT|明示なし|不足|
|SERVER_TIME reference|10:00–14:00|明示なし|不足|
|Weekdays|Mon–Fri enabled|明示なし|不足|
|Mon/Fri optional block|server-time block windows|明示なし|不足|
|GMT fail-safe|offset取得失敗時new cycle停止|明示なし|不足|
|News overall|MT5 Calendar|NEWS_CLEAR metadataのみ|部分一致|
|News stop mode|STOP_NEW_CYCLE_ONLY / MANAGE_ONLY|明示なし|不足|
|News fail mode|allow / stop new / manage only|明示なし|不足|
|High impact|default ON, before180/after120|明示なし|不足|
|Medium/Low|default OFF|明示なし|不足|
|Spread max|0=off|SPREAD_OK metadataのみ|部分一致|
|ATR1/ATR2|2本の独立range|ATR_RANGE schemaで表現可能|部分一致|

**設計上の注意:** Time/News/Spread/ATRをすべてO01固有Partにしない。新パネルのFILTER構想とStrategy gateの責務を整理し、汎用Partとして再利用する。

## 8. DD安全機能との関係

|原典処理|値|Roleとの関係|現状|判定|
|---|---|---|---|---|
|Warning|8%|表示/警告。取引自体を即停止しない|Builder seed外|Builder外/Global Safety|
|Grid Pause|12%|GRID追加停止。既存保護は継続|seed外|**接続不足**|
|Emergency Close|15%|open positionがある場合、通常Manageより先に全決済|seed外|Builder外/Global SafetyだがDispatcher優先順必須|
|After Emergency|STOP_UNTIL_NEXT_SESSION default|新規再開をlock|ENTRYのemergency stateへ影響|接続不足|
|DD mode|BALANCE_EQUITY default / PEAK_EQUITY option|Safety計算|Builder外|Global Safety|
|persistent lock/peak|maxDD/riskPeak/lockをGlobalVariable保存|再起動復元|Builder外|Execution/Safety|

**結論:** 8/12/15自体をO01の40 Partsへ埋め込むのではなく、Global Safetyを維持する。ただし **12% Grid Pause と15% EmergencyのDispatcher優先順、Emergency Lock→ENTRY gate** はStrategy実行経路と明示的に接続する。

## 9. Position / Lot管理

|項目|原典|現状|判定|
|---|---|---|---|
|position識別|Symbol + Magic + side|Evaluator context化|実注文前に要確認|
|hedging前提|HEDGING account必須|40 Parts外|Builder外|
|initial lot|0.01|不完全|部分一致|
|grid lot|latest lot ×1.50|max 5.00|概ね一致|
|max total side lots|1.20|一致|一致|
|max side orders|10|一致|一致|
|normalize lot|broker min/max/step + MathRound|不足|Execution不足|
|weighted average|volume weighted|AVG_PRICE|一致/Runtime要確認|
|newest position|POSITION_TIME newest|LAST_PRICE metadata|部分一致|
|restart one/bar|lastBuyOrderBar/lastSellOrderBarは原典ではruntime変数|Builder demoでは復元設計が必要|不足|

## 10. O01特有/例外処理の分類

|処理|分類|40 Partsへ入れるか|
|---|---|---|
|DEMO account only|Host Safety|入れない。Demo execution gate|
|XAUUSD restriction|O01 Host restriction|汎用Builder Partには入れない|
|HEDGING required|Execution capability|入れない。execution preflight|
|Economic Calendar fail-safe|Generic FILTER/Safety|汎用化|
|Close opposite option|Strategy EXIT option|汎用Part/parameter候補|
|Overlap|Strategy MANAGE|**追加必要**|
|persistent emergency lock|Global Safety state|Partではなくstate input|
|persistent max DD|Global Safety/telemetry|Partではない|
|panel/dashboard|UI|Partではない|
|close reason log|Telemetry|Partではない|

## 11. 過去Parity証拠との整合
2026-10-03の既存証拠では:
- ENTRY: 114409/114409
- MANAGE: 200/200
- EXIT: 140/140
- integrated ENTRY→MANAGE→EXIT: 各114409/114409

これは既存Evaluatorと限定された仮想contextでの一致証拠として保持する。

ただし、今回の照合で次が未証明と確定:
1. **4 Role ENTRY→GRID→MANAGE→EXIT** の保存40 Partsだけによる完全再構成
2. Flat InterpreterのAND/ORでbranch意味が原典と一致すること
3. Time/News/Spread/ATR×2を含む完全ENTRY gate
4. DD12% Grid Pause / 15% Emergencyとの実行順接続
5. Overlap
6. Single Money TP / Basket 100pt Fixed TP
7. close-opposite option
8. restartをまたぐruntime state
9. 実broker order lifecycle

したがって過去PASSを否定しないが、**O01-R3の完全Parity PASSとして流用しない。**

## 12. O01-R2 修正優先順位

### P0 — 先に直さないと40 Parts照合が成立しない
1. Part Schemaを正規4 Role **ENTRY / GRID / MANAGE / EXIT** にする
2. InterpreterのAND/OR branch/group semanticsを確定
3. Generic O01 seedを4 Roleへ再配置
4. 原典のphase/evaluation orderをDispatcher仕様として固定

### P1 — 原典O01の欠落意味を追加
5. ENTRY: Emergency/Time/News/Spread/ATR1/ATR2/TradeSide/one-bar
6. GRID: DD Grid Pause/Time policy/News/Spread/last-price/distance-reached
7. MANAGE: Overlap
8. EXIT: Single vs Basket Fixed TP、Money TP、close-opposite

### P2 — Stateful Runtime
9. trailing state
10. last-order-bar state
11. weighted avg/newest position context
12. emergency lock state input

### P3 — Demo execution前
13. lot normalization
14. Symbol + Magic isolation
15. restart recovery
16. duplicate prevention
17. send/close failure handling

## 13. Gate O01-R1 判定
**O01-R1 Source Inventory / 照合表: COMPLETE**

ただしこれはコードのCompile PASSやRuntime PASSではない。

次Gate:
**O01-R2 — 40 Parts reproduction**

最初の実装単位はP0-1:
**Part Schemaを ENTRY / GRID / MANAGE / EXIT の4 Role正規順へ統一する。**

その後、P0-2のInterpreter branch/group semanticsへ進む。
