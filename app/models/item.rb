class Item
	attr_accessor :item_name, :attributes_array

	def initialize(name)
		@item_name = name
		@attributes_array = Array.new()
  	end

  	def add_attributes(hash)
  		@attributes_array.push(Hash[hash.map {|k, v| [k.intern, v] }])
  	end

  	def add_single_attribute(att_name, att_value)
		@attributes_array.push(Hash[att_name.intern => att_value])
  	end

  	def to_aws_hash
  		attr_array = Array.new
  		@attributes.each do |ele|

  			item_hash[:name] = @item_name
  			item_hash[:attributes] = @attributes_array
  		end
  	end


  	def to_s
  		result = String.new
  		result << "Name: " <<@item_name <<"\n."
  		@attributes_array.each do |ele|
  			result << "\tAttributes:\n"
  			ele.each do |k,v|
  				result << "\t\t" << k.to_s << ":\t" << v.to_s << "\n."
  			end
  		end
  		result
  	end
end

