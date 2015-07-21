class ApiHandler

  def initialize
    @app_delegate ||= UIApplication.sharedApplication.delegate
    @conn ||= AFMotion::Client.build('http://happiness-metric.herokuapp.com/') do
      header "Accept", "application/json"
      response_serializer :json
    end
  end

  def show_group
    params = { user_id: @app_delegate.user.id }

    @conn.get("groups/#{@app_delegate.group.id}", params) do |result|
      @app_delegate.group.reset if result.failure?
      process_response(result)
    end
  end

  def create_group(group, &block)
    params = { group: group, user_id: @app_delegate.user.id }
    puts "----- group: #{group.inspect}"
    @conn.post("groups", params) do |result|
      process_response(result)
      block.call(result)
    end
  end

  def join_group(group, &block)
    params = { group: { name: group[:name], password: group[:password] }, user_id: @app_delegate.user.id }

    @conn.post("groups/join", params) do |result|
      process_response(result)
      block.call(result)
    end
  end

  def update_group(group, &block)
    params = { group: group, user_id: @app_delegate.user.id }

    @conn.put("groups/#{@app_delegate.group.id}", params) do |result|
      process_response(result)
      block.call(result)
    end
  end

  def update_score
    params = { group_id: @app_delegate.group.id, user_id: @app_delegate.user.id, score: @app_delegate.score.score }

    @conn.put("scores/#{@app_delegate.score.id}", params) do |result|
      process_response(result)
    end
  end

  def process_response(result)
    if result.success?
      puts "RESULT SUCCESS :) - #{result.object}"
      update_local_data(result.object)
    elsif result.failure?
      puts "RESULT ERROR :( - #{result.object}"
      if result.object['error']
        App.alert(result.object['error'])
      else
        App.alert("An error occurred.")
        # App.alert(result.error.localizedDescription)
      end
    end
  end

  def update_local_data(data)
    ['group', 'score'].each do |data_type|
      data[data_type].each do |key, value|
        @app_delegate.send(data_type).send("#{key}=", value)
      end
      @app_delegate.send(data_type).save
    end
  end

end