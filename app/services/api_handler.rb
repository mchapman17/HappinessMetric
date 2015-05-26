class ApiHandler

  def initialize
    @app_delegate ||= UIApplication.sharedApplication.delegate
    @conn ||= AFMotion::Client.build('http://localhost:3000/') do
      header "Accept", "application/json"
      response_serializer :json
    end
  end

  def join_group(group_name, password)
    params = { group_name: group_name, password: password, user_id: @app_delegate.user.id }

    success = @conn.post("happiness/join_group", params) do |result|
      if result.success?
        puts "*** #{result.object}"
        # @app_delegate.group = Group.new(result.object["group"])
        result.object["group"].each do |k,v|
          @app_delegate.group.send("#{k}=", v)
        end
        @app_delegate.group.save
        puts "*** name: #{@app_delegate.group.name}"
        puts "*** score: #{@app_delegate.group.max_score}"
        puts "*** user count: #{@app_delegate.group.user_count}"

        @app_delegate.user.score = result.object[:user][:score].to_f
        @app_delegate.user.save
        true

      elsif result.operation.response.statusCode.to_s =~ /40\d/
        puts "--- status code 40* - #{result.object}"
        App.alert("Joining group failed.")
        false

      elsif result.failure?
        puts "--- error - #{result.object}"
        App.alert(result.error.localizedDescription)
        false
      end
    end

    success
  end

  def create_group(group_name, password)
    params = { group_name: group_name, password: password, user_id: @app_delegate.user.id }
    @conn.post("happiness/create_group", params) do |result|
      if result.success?
        @app_delegate.group = Group.new(result.object["group"])
        @app_delegate.group.save
        @app_delegate.user.score = 0
        @app_delegate.user.save

      elsif result.operation.response.statusCode.to_s =~ /40\d/
        puts "--- status code 40* - #{result.object}"
        App.alert("Group creation failed.")
      elsif result.failure?
        puts "--- error - #{result.object}"
        App.alert(result.error.localizedDescription)
      end
    end
  end

  def get_group_average_score
    @conn.get("happiness/group_average_score/#{@app_delegate.group.id}") do |result|
      process_score_response(result)
    end
  end

  def set_user_score
    params = { group_id: @app_delegate.group.id, user_id: @app_delegate.user.id, score: @app_delegate.user.score }
    puts "-------- set user score:  #{params}"
    @conn.post('happiness/user_score', params) do |result|
      process_score_response(result)
    end
  end

  def process_score_response(result)
    if result.success?
      puts "------------ score response:  #{result.object}"
      @app_delegate.group.average_score = result.object["group_average_score"]
      @app_delegate.group.user_count = result.object["group_user_count"]
    elsif result.operation.response.statusCode.to_s =~ /40\d/
      App.alert("Score update failed.")
    elsif result.failure?
      App.alert(result.error.localizedDescription)
    end
  end

end