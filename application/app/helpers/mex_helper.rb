module MexHelper
 #def error_messages_for_group
    #errors = nil
    #unless @group.errors.empty?
      #errors = Hash.new
      #@group.attributes.keys.each do |k|
        #unless @group.errors.on(k.to_sym).nil?
          #@group.errors.on(k.to_sym).each do |error|
            #unless error.nil?
              #begin
                #errors[k.to_sym] << error
              #rescue
                #errors[k.to_sym] = Array.new
                #errors[k.to_sym] << error
              #end
            #end
          #end
        #end
      #end
    #end
    ##return errors
    #unless errors.nil? %>
        #<% unless group_errors[:name].nil? %>
          #<% group_errors[:name].each do |error| %>
            #<tr>  
              #<td class="error" style="width: 194px;">
                #<%= error %>
              #</td>
            #</tr>
          #<% end %>
        #<% end %>
      #<% end %>
    
  #end

  def error_messages_for_group(attr)
    r = ''
    errors = @group.errors.on(attr)
    unless errors.nil?
      #r << label(nil, nil,'', :class => "sso_login_label")
      r << '<ul class="sso_login_errors">'
      errors.each do |e|
        r << '<li>' + e + '</li>'
      end
      r << '</ul>'
      
      #r << '<div>'
      #r << label(nil, nil,'', :class => "sso_login_label")
      #r << el
      #r << '</div>'
    end
    r
  end
  
  def error_messages_for_user(attr)
    r = ''
    errors = @user.errors.on(attr)
    unless errors.nil?
      #r << label(nil, nil,'', :class => "sso_login_label")
      r << '<ul class="sso_login_errors">'
      errors.each do |e|
        r << '<li>' + e + '</li>'
      end
      r << '</ul>'
      
      #r << '<div>'
      #r << label(nil, nil,'', :class => "sso_login_label")
      #r << el
      #r << '</div>'
    end
    r
  end
  
  #def error_messages_for_user
    #errors = nil
    #unless @user.errors.empty?
            #errors = Hash.new
      #@user.attributes.keys.each do |k|
        #unless @user.errors.on(k.to_sym).nil?
          #@user.errors.on(k.to_sym).each do |error|
            #unless error.nil?
              #begin
                #errors[k.to_sym] << error
              #rescue
                #errors[k.to_sym] = Array.new
                #errors[k.to_sym] << error
              #end
            #end
          #end
        #end
      #end
    #end
    #return errors
  #end
end
