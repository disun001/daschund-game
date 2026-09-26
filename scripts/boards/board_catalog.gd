class_name BoardCatalog
extends RefCounted

## The hand-authored boards, in their fixed play order.
static func all() -> Array[BoardData]:
	return [
		# 1. Intro: one bay of Water, one Apple.
		BoardData.new([
			"......",
			"......",
			"WWA...",
			"......",
			"......",
			"......",
		], 8),
		# 2. Water-cornered pocket with a Cherry.
		BoardData.new([
			"WWW...",
			"W.C...",
			"W.....",
			"......",
			"......",
			"......",
		], 8),
		# 3. Freestanding lake (Water-Water anchors) plus a Bee to avoid.
		BoardData.new([
			"......",
			".WW...",
			".WW.B.",
			"......",
			"..A...",
			"......",
		], 9),
		# 4. Bee beside the prize.
		BoardData.new([
			"W.....",
			"W.....",
			"WBC...",
			"W.....",
			"W.....",
			"......",
		], 8),
		# 5. Two bays, two Apples: multiple Enclosures.
		BoardData.new([
			"..WW..",
			"..A...",
			"......",
			"......",
			"...A..",
			"..WW..",
		], 10),
		# 6. Wider board, tight cap.
		BoardData.new([
			"........",
			".W....C.",
			".W..B...",
			"........",
			"..A...W.",
			"......W.",
			"........",
			"........",
		], 10),
	]
