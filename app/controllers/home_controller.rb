class HomeController < ApplicationController


  def check_seesion()
        @aws_key_id = session[:aws_key_id]
        @aws_key = session[:aws_key]
        if !@aws_key_id 
            @session_state = false
        else
            @simpledb = Aws::SimpleDB::Client.new(
                :access_key_id => @aws_key_id,
                :secret_access_key => @aws_key,
                :region => 'eu-west-1')
            @session_state = true
        end
  end

  def index
  end 

  def bye
  	@aws_key_id = session[:aws_key_id]
        @aws_key = session[:aws_key]

        @simpledb = Aws::SimpleDB::Client.new(
            :access_key_id => @aws_key_id,
            :secret_access_key => @aws_key,
            :region => 'eu-west-1')

        begin
            @resp = @simpledb.list_domains(
                max_number_of_domains: 10,
                ).domain_names
            render :text => @resp
        rescue Aws::SimpleDB::Errors::ServiceError
            false
        end
        true
  end
end

