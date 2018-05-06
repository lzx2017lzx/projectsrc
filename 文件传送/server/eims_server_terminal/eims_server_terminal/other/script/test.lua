local snap = require "snapshot"

local str = "aa"

str = table.concat(str, "bb")

print(str)

concatstr = function(...)
	for i, v in ipairs{...} do
 		labels_path = labels_path .. "/" .. message_labels[v]
  	end
end
