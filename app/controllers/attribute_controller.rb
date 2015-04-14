class AttributeController < ApplicationController
    before_action :check_seesion
    respond_to :html, :js

    def check_seesion
        @aws_key_id = session[:aws_key_id]
        @aws_key = session[:aws_key]
        if !@aws_key_id 
            @session_state = false
            flash[:warning] = "Sorry! Please enter your AWS credential."
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            @session_state = true
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
            # @result = get_attributes(@simpledb, @domain_name, @item_name)
            @list_items = list_items(@simpledb, @domain_name, 100, ""," itemName() = '#{@item_name}'")


            @all_attributes_names = get_uniq_attribute_names_from_items(@list_items)
            @item_obj_array = format_request_to_obj(@all_attributes_names, @list_items.items)
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

    def put_ajax
        @domain_name = params[:domain_name]
        @attr_name = params[:attr_name]
        @item_name = params[:item_name]
        @is_replace = params[:is_replace]
        if !@is_replace || @is_replace.to_s.size<1
            @@is_replace = false
        end
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


                @ha = {items: [
                    {
                        name: @item.item_name,
                        attributes: @item.attributes_array,
                        },
                        ]}

                        put_attributes(@simpledb,@domain_name,@item)
                    end

                end
                redirect_to action: :list, domain_name: @domain_name
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

    def delete_modal
        @domain_name = params[:domain_name]
        @item_name = params[:item_name]
        @attr_name = params[:attr_name]
        @attr_value = params[:attr_value]

        @attr_array = @attr_value.split(" ")


    end


    def delete
        if !check_seesion
            redirect_to controller: :home, action: :index
        end

        @domain_name = params[:domain_name]
        @item_name = params[:item_name]
        @attr_name = params[:attr_name]
        @attr_value = params[:attr_value]
        @attr_value_delete = params[:attr_value_delete]
        @attr_array_temp = @attr_value.split(" ")
        @attr_array = Array.new

        if @attr_value_delete && @attr_value_delete.size>0 



        @attr_value_delete.each do |k,v|
            @attr_array.push(@attr_array_temp[k.to_i])
        end


        @item = Hash.new
        @item[:name] = @item_name
        @item[:attributes] = Array.new
        @attr_array.each do |ele|
            @attribute = Hash.new
            @attribute[:name] = @attr_name
            @attribute[:value] = ele
            @item[:attributes].push(@attribute)
        end


        if request.post?
            delete_attribute(@domain_name,[@item])
        end
        end
        redirect_to action: :list, domain_name: @domain_name
        
    end

    def delete_attribute(domain_name,items)
        @resp = @simpledb.batch_delete_attributes(
  # required
  domain_name: domain_name,
  # required
  items: [items[0]],
  )
    end

 def select

        if !check_seesion
            redirect_to controller: :home, action: :index
        end

        
        @where = params[:where]
        @order_by = params[:order_by]
        @sort_instructions = params[:sort_instructions]
        @limit = params[:limit]
        


        if request.post?
            if params[:select].empty?
                @select = "*"
            else
                @select = params[:select]
            end

            if params[:from].empty?
                flash[:warning] = "Sorry! Please enter a domain name."
                redirect_to controller: :attribute, action: :select
                return
            else
                @from = params[:from]
            end

            if !params[:order_by].empty?
                @order_by_str = 'order by ' + params[:order_by].to_s
            else
                @order_by_str = ""
                @sort_instructions = " "
            end

            if !params[:where].empty?
                @where_str = 'where ' + params[:where].to_s
            end

            if params[:limit].empty?
                @limit = "100"
            end

            if params[:next_page_token] && params[:next_page_token].empty?
                @next_page_token = ""
            else
                @next_page_token = params[:next_page_token]
            end

            @select_query = "select #{@select} from #{@from} #{@where_str} #{@order_by} #{@sort_instructions} limit #{@limit}"
            @list_items = select_items(@select, @from, @where_str, 
                                    @order_by_str, @sort_instructions, @limit, @next_page_token)
            @all_attributes_names = get_uniq_attribute_names_from_items(@list_items)
            @next_page_token = @list_items.next_token

            @item_obj_array = format_request_to_obj(@all_attributes_names, @list_items.items)
            @select_query = "select #{@select} from #{@from} #{@where_str} #{@order_by} #{@sort_instructions} limit #{@limit}"

            @domain_name = @from
           

        end


    end


    def select_items(select, domain_name, where, order_by, sort_instructions, limit, next_page_token = '')
        begin
            @resp = @simpledb.select(
                select_expression: "select #{select} from #{domain_name} #{where} #{order_by} #{sort_instructions} limit #{limit}",
                next_token: next_page_token,
                consistent_read: true,)
            #TODO need catch exception here
        end
        #select * from mydomain where attr1 = 'He said, "That''s the ticket!"'  select * from mydomain where attr1 = "He said, ""That's the ticket!"""

        @resp
    end

    def select_ajax
        @domain_name = params[:domain_name]
    end

    def list
        if params[:domain_name]
            if !params[:domain_name].empty?
                @domain_name = params[:domain_name]
            end
        else
            flash[:warning] = "Sorry! Please enter a domain name."
            redirect_to controller: :domain, action: :list
            return 
        end

        @select = "*"
        if params[:select]
            if !params[:select].empty?
                @select = params[:select]
            end
        end

        if params[:where]
            if !params[:where].empty?
                @where_str = 'where ' + params[:where].to_s
            end
        else
            @where_str = ""
        end

        @order_by_str= ""
        @sort_instructions = ""
        if params[:order_by]
            if !params[:order_by].empty?
                @order_by_str = 'order by ' + params[:order_by].to_s
                @sort_instructions = params[:sort_instructions]
            end
        end
        

        @next_page_token = params[:next_page_token]
        if !@next_page_token
            @next_page_token = ""
        end

        @max_number_of_items = params[:max_number_of_items]
        if !@max_number_of_items ||@max_number_of_items == ""
            @max_number_of_items = 100
        end

        if params[:domain_name]
            if !params[:domain_name].empty?
                @domain_name = params[:domain_name]
            end
        else
            flash[:warning] = "Sorry! Please enter a domain name."
            redirect_to controller: :attribute, action: :list
            return 
        end

        if !check_seesion
            redirect_to controller: :home, action: :index
        else
            @list_items =select_items(@select, @domain_name,  @where_str, @order_by_str, @sort_instructions, @max_number_of_items, @next_page_token)

            #make sure there is items in the domain
            if @list_items.items.size == 0
                flash[:info] ="No item in the domain."
                return
            end
            @all_attributes_names = get_uniq_attribute_names_from_items(@list_items)
            @next_page_token = @list_items.next_token

            @item_obj_array = format_request_to_obj(@all_attributes_names, @list_items.items)

        end
    end

def format_request_to_obj(all_attr_names, items)
    @item_obj_array = Array.new
    items.each do |item|
        @item = NewItem.new(item.name)

            #add all possible attributes name to the new created item
            all_attr_names.each do |name|
                @item.add_attribute(name, "")
            end
            #add all attributes the item really have
            item.attributes.each do |att|
                @whith_space =  @item.get_attribute_by_name(att.name.to_s).size>0 ? "\n" : "" 
                @item.add_attribute(att.name.to_s, @item.get_attribute_by_name(att.name.to_s)+@whith_space+att.value.to_s)
            end
            @item_obj_array.push(@item)
        end
        return @item_obj_array
    end

    def get_uniq_attribute_names_from_items(list_items)
        @attr_names= Array.new

        list_items.items.each do |item|
            @attr_names <<  ((item.attributes.collect{ |ele| ele.name}).uniq)
        end

        if @attr_names && @attr_names.flatten.size >0
            @attr_names.flatten!.uniq!
        end
        @attr_names
    end

end
