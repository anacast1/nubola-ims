class Period

  attr_accessor :concurrency, :connected_users

  def initialize(from,to,group,connected_users=[])
    @from = from.to_s(:db)
    @to = to.to_s(:db)
    @group = group
    @connected_users = connected_users
    @concurrency = connected_users.size
    if @group.id == -1
      @registres=Registre.find :all, :conditions => ["action IN ('login','logout') AND created_at BETWEEN ? AND ?",@from,@to], :order => "created_at"
    else
      @registres=Registre.find :all, :conditions => ["group_id=? AND action IN ('login','logout') AND created_at BETWEEN ? AND ?",@group.id,@from,@to], :order => "created_at"
    end
  end

  def process_old(from)
    if @group.id ==  -1
      oldregs = Registre.find :all, :conditions => ["action IN ('login','logout') AND created_at BETWEEN ? AND ?",from.to_s(:db),@from], :order => "created_at"
    else
      oldregs = Registre.find :all, :conditions => ["group_id=? AND action IN ('login','logout') AND created_at BETWEEN ? AND ?",@group.id,from.to_s(:db),@from], :order => "created_at"
    end
    oldregs.sort.each do |registre|
      if (registre.action == "login" and !(@connected_users.include? registre.user_id) )
        @connected_users << registre.user_id
      elsif (registre.action == "logout" and @connected_users.include? registre.user_id )
        @connected_users.delete registre.user_id
      end
    end
  end

  def process
    @registres.sort.each do |registre|
      # comprovem si l'usuari esta en demo
      u = User.find registre.user_id
      next if u.demo?
      if (registre.action == "login" and !(@connected_users.include? registre.user_id) )
        @connected_users << registre.user_id
        @concurrency = @connected_users.size if @connected_users.size > @concurrency
      elsif (registre.action == "logout" and @connected_users.include? registre.user_id )
        @connected_users.delete registre.user_id
      end
    end
  end

end
