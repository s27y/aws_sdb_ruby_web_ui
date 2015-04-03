class NewItem
	attr_accessor :item_name, :attributes_hash

	def initialize(name)
		@item_name = name
		@attributes_hash = Hash.new
  	end

  	def add_attribute(att_name, att_value)
		@attributes_hash[att_name.intern] = att_value
  	end

  	def to_s
  		result = String.new
  		result << "Name: " <<@item_name <<"\n."
  		@attributes_hash.each do |k,v|
  			result << "\tAttributes:\n"
  			result << "\t\t" << k.to_s << ":\t" << v.to_s << "\n."
  		end
  		result
  	end
end
