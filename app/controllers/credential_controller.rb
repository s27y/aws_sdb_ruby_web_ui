class CredentialController < ApplicationController
    def check_seesion(aws_key_id,aws_key)
        @simpledb = Aws::SimpleDB::Client.new(
            :access_key_id => aws_key_id,
            :secret_access_key => aws_key,
            :region => 'eu-west-1')

        begin
            @resp = @simpledb.list_domains(
                max_number_of_domains: 10,
                ).domain_names
        rescue Aws::SimpleDB::Errors::ServiceError
            return false
        end
        return true
    end

  def add
  	if request.post?

      session[:aws_key_id] = nil
      session[:aws_key] = nil

  		@aws_key_id = params[:aws_key_id]
  		@aws_key = params[:aws_key]

  		#TODO check key pair
  		@key_pair = check_seesion(@aws_key_id,@aws_key)

  		if @key_pair == true 
  				session[:aws_key_id] = @aws_key_id
  				session[:aws_key] = @aws_key
          flash[:success] = "Welcome! Your AWS credential is valid."
  				redirect_to controller: :home, action: :index
  		else
        flash[:warning] = "Sorry! Please enter your AWS credential again."
  			redirect_to controller: :home, action: :index
  		end
  	end
  end

  def remove
  	session[:aws_key_id] = nil
  	session[:aws_key] = nil
    flash[:success] = "Bye! Your AWS credential is removed."
  	redirect_to controller: :home, action: :index
  end
end
