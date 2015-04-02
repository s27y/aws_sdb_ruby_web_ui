class CredentialController < ApplicationController
    def check_seesion
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
        rescue Aws::SimpleDB::Errors::ServiceError
            false
        end
        true
    end

  def add
  	if request.post?
  		@aws_key_id = params[:aws_key_id]
  		@aws_key = params[:aws_key]

  		#TODO check key pair
  		@key_pair = true

  		if @key_pair 
  				session[:aws_key_id] = @aws_key_id
  				session[:aws_key] = @aws_key
  				redirect_to controller: :home, action: :index
  			
  		else
  			redirect_to controller: :home, action: :index
  		end
  	end
  end

  def remove
  	session[:aws_key_id] = nil
  	session[:aws_key] = nil
  	redirect_to controller: :home, action: :index
  end
end
