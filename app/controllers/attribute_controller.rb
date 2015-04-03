class AttributeController < ApplicationController

    def check_seesion
        @aws_key_id = session[:aws_key_id]
        @aws_key = session[:aws_key]
        if !@aws_key_id 
            false
        else
            true
        end
    end

    def get
        if !check_seesion
            redirect_to controller: :home, action: :index
        end
        @domain_name = params[:domain_name]
        @item_name = params[:item_name]

        if request.post?
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            @result = get_attributes(@simpledb, @domain_name, @item_name)
        end

    end

    def get_attributes(simpledb, domain_name, item_name)
        begin
            @resp = simpledb.get_attributes(
        # required
        domain_name: domain_name,
        # required
        item_name: item_name,
        consistent_read: true,
        )
        rescue Aws::SimpleDB::Errors::NoSuchDomain => e
            return "error"
        end
        
    end


    def att_hash_to_aws_att_hash(hash)
        array = Array.new
        hash = {"name_1" => 'name_value', "Isidora" => 35, "some" => 65}
        hash.each { |name, value| array.push(Hash[name: name, value: value])}

        array
    end

    def test_hash
        h = Array.new

        attribute1= {name: "name1", value: "value1", replace: true}
        attribute2= {name: "name2", value: "value2", replace: true}
        attribute3= {name: "name3", value: "value3", replace: true}
        h.push(attribute1)
        h.push(attribute2)
        h.push(attribute3)
        render :text => h.to_s
    end

    def put
        if !check_seesion
            redirect_to controller: :home, action: :index
        end
        @domain_name = params[:domain_name]
        @attributes = params[:attributes]
        @item_name = params[:item_name]

        if !@domain_name
            @domain_name = "glacier"
        end

        if @attributes && @item_name
            @hash = Hash[@attributes['0']]
            #render :text => @hash['name']
        end

        if true

        if false
            redirect_to controller: :home, action: :index
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
        end

        if request.post?
            @item = Item.new(@item_name['0'].to_s)
            @item.add_attributes(@hash)
            @item.add_attributes({ name: "2nd_name", value: "2nd_value" })


            @ha = {items: [
                    {
                        name: @item.item_name,
                        attributes: @item.attributes_array,
                    },
                        ]}

            #render :text => @ha
            #render :text => @item.to_s
            #@result = get_attributes(@simpledb, @domain_name, @item.item_name).attributes[1][:value]
            render :text => put_attributes(@simpledb,@domain_name,@item)
        end

        end

    end #END put

    def put_attributes(sdb,domain_name,item_obj)
        begin
            @resp = sdb.batch_put_attributes(
                domain_name: domain_name,
                items: [
                        {
                        name: item_obj.item_name,
                        attributes: item_obj.attributes_array,
                        },
                        ],)
        rescue Aws::SimpleDB::Errors::NoSuchDomain => e
            return "error"
        end
        

    end


def delete
end

def select
    @domain_name = params[:domain_name]
    render :text => @domain_name
end

    def list
    if !params[:max_number_of_row]
            @max_number_of_row = 100
        else
            @max_number_of_row = params[:max_number_of_row]
        end

        @next_page_token = params[:next_page_token]

        @domain_name = params[:domain_name]

        if !@domain_name
            @domain_name = "glacier"
        end

        if !check_seesion
            redirect_to controller: :home, action: :index
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            @list_items = list_items(@simpledb, @domain_name, 10)

        @all_attributes_names = get_uniq_attribute_names_from_items(@list_items)


        @item_obj_array = Array.new
        @list_items.items.each do |item|
            @item = NewItem.new(item.name)
            #add all possible attributes name to the new created item
            @all_attributes_names.each do |name|
                @item.add_attribute(name, "")
            end
            #add all attributes the item realy have
            item.attributes.each do |att|
                @item.add_attribute(att.name.to_s, att.value.to_s)
            end
            @item_obj_array.push(@item)
        end

        end
    end
    


    def get_uniq_attribute_names_from_items(list_items)
        @attr_names= Array.new

        list_items.items.each do |item|
            @attr_names <<  ((item.attributes.collect{ |ele| ele.name}).uniq)
        end
        @attr_names.flatten!.uniq!
    end

    def list_items(sdb, domain_name="glacier", max_number_of_attributes=100, next_page_token="")
        begin
            @resp = sdb.select(
                    select_expression: "select * from #{domain_name} limit #{max_number_of_attributes}",
                    next_token: next_page_token,
                    consistent_read: true,)
                #TODO need catch exception here
        end


        @resp
    end


end
