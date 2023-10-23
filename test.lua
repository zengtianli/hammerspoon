-- create a new chooser object with some choices
local chooser = hs.chooser.new(function(choice)
	-- do something with the choice
end)
chooser:choices({
	{ text = "Option 1", subText = "Some details" },
	{ text = "Option 2", subText = "Some details" },
	{ text = "Option 3", subText = "Some details" },
	{ text = "Option 4", subText = "Some details" }
})

-- enable multiple selection
chooser:multiSelect(true)

-- show the chooser
chooser:show()
