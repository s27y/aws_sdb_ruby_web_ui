class DomainController < ApplicationController
    def check_seesion

        @aws_key_id = session[:aws_key_id]
        @aws_key = session[:aws_key]
        if !@aws_key_id 
            false
        else
            true
        end
    end

    def add
        if !check_seesion
            redirect_to controller: :home, action: :index
        else            
            if request.post?
                @simpledb = Aws::SimpleDB::Client.new(
                    :access_key_id => @aws_key_id,
                    :secret_access_key => @aws_key,
                    :region => 'eu-west-1')

                @domain_name = params[:domain_name]
                add_domain(@simpledb,@domain_name)
                #render :text => @domain_name
                redirect_to action: :list
            end
        end
    end

    def add_domain(sdb, domain_name)
        begin
        @resp = sdb.create_domain(domain_name: @domain_name,)
        end
    end


    def delete
        if !check_seesion
            redirect_to controller: :home, action: :index
        else            
            if request.post?
                @simpledb = Aws::SimpleDB::Client.new(
                    :access_key_id => @aws_key_id,
                    :secret_access_key => @aws_key,
                    :region => 'eu-west-1')

                @domain_name = params[:domain_name]
                delete_domain(@simpledb,@domain_name)
                #render :text => @domain_name
                redirect_to action: :list

            end 
        end
    end

    def delete_domain(sdb,domain_name)
        begin
            @resp = sdb.delete_domain(domain_name: @domain_name,)
        rescue Aws::SimpleDB::Errors::InvalidParameterValue
            #TODO add flash 
        end
    end

    def list
        if !params[:max_number_of_domains]
            @max_number_of_domains = 10
        else
            @max_number_of_domains = params[:max_number_of_domains]
        end

        @next_page_token = params[:next_page_token]

        if !check_seesion
            redirect_to controller: :home, action: :index
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            @domains = list_domains(@simpledb, @max_number_of_domains, @next_page_token)
            
        end
    end


    def list_domains(sdb, max_number_of_domains, next_token="")
        begin
                @domains = sdb.list_domains(
                    max_number_of_domains: @max_number_of_domains,
                    next_token: next_token,
                    )
                #TODO need catch exception here
            end
            @domains
    end

    def metadata
        @domain_name = params[:domain_name]
        if !check_seesion
            redirect_to controller: :home, action: :index
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            metadata_domain(@simpledb,@domain_name)
        end
    end

    def metadata_domain(sdb,domain_name)
        @resp = sdb.domain_metadata(domain_name: domain_name)
        render :text => @resp.item_count 
        #item_names_size_bytes attribute_name_count attribute_names_size_bytes attribute_value_count attribute_values_size_bytes timestamp
    end

end


