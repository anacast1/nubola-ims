class ConsumAdaptor < ApplicationAdaptor

  def registra consum

    consum.consumitems.each do |ci|
      r = Consum.create(
        :text     => consum.to_xml.to_s,
        :action   => "consum",
        :group_id => consum.gid,
        :app_id   => App.find_by_unique_app_id(consum.app_id).id,
        :amount   => ci.text 
      )
    end
    
  end

end
