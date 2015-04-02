class HomeController < ApplicationController
  def index

    if session[:aws_key_id] && session[:aws_key]
        flash[:notice] = "Your key pair is valid"
    else
      flash[:notice] = "Your key pair is invalid"
      
    end
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

