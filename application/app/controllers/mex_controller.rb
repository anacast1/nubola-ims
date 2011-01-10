class MexController < ApplicationController
    layout  'sso'
    
    def new_group
      if request.get?
        @group = Group.new
        @user = User.new
      elsif request.post?
        #if params[:new_group]
          @group = Group.new(params[:group])
          @user = User.new(params[:user])

          # save group and admin user
          group_saved = @group.save

          @user.role = "groupadmin"
          @user.group_id = @group.id
          user_saved = @user.save

          if user_saved and group_saved
            # user and group created successfully
            redirect_to :action => :confirmation, :id => @user
          else
            if user_saved
              @user.destroy
            end
            if group_saved
              @group.destroy
            end
          end
        #elsif params[:cancel]
        #  redirect_to :action => :index
        #end
      end
    end

    def confirmation
      @user = User.find params[:id]
      if @user.confirmed == false
        if params[:extra] == nil
          # if the request is empty means we must send a confirmation email
          extra = "0"
          while extra == "0" do
            extra = srand.to_s
          end
          if @user.update_attributes(:confirmation_string => extra, :password => "", :password_confirmation => "")
	    url = url_for(:controller => "mex", 
                          :action => "confirmation", 
                          :id => @user.id, 
                          :extra => @user.confirmation_string)
            email = ConfirmationMailer.create_confirmation(@user, url)
            ConfirmationMailer.deliver(email)
          end
          #render :layout => false
          flash[:notice] = "<p>#{t("an_email_has_been_sent_to")}<b>#{h(@user.email)}</b>, #{t("to_verify_email")}.</p><p>#{t("follow_instructions_in_the_email")}.</p>"
          redirect_to :controller => :sso, :action => :login
        else
          # if the request is not empty, means we are receiving a confirmation email
          extra = params[:extra]
          if @user.confirmation_string == extra
            if @user.update_attributes(:confirmed => true, :password => "", :password_confirmation => "")

              message = @user.adduser_message [], true # this includes GENERAL
              unless system("#{Setting.oappublish} 'IMS' '#{message}'")
                logger.info("Problem publishing adduser message")
              end

              flash[:notice]  = "#{I18n.t("your_account")}#{h(@user.group.name)}#{I18n.t("has_been_activated")}."
            else
              flash[:notice]  = "#{I18n.t("problem_activating_account")}#{@user.group.name}."
            end
          else
            flash[:notice]  = "#{I18n.t("invalid_confirmation_link")}."
          end
          redirect_to :controller => "sso", :action => "login"
        end
      else
        # the user was already confirmed
        flash[:notice]  = "#{I18n.t("your_account")}#{@user.group.name}#{I18n.t("was_already_active")}."
        redirect_to :controller => "sso", :action => "login"
      end
    end

    def pdf_service_terms
      send_file "#{RAILS_ROOT}/public/doc/#{I18n.locale}/service_terms.pdf", :type => 'application/pdf', :disposition => 'attachment'
    end
end

