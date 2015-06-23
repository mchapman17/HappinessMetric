class ApiHandler

  def initialize
    @app_delegate ||= UIApplication.sharedApplication.delegate
    @conn ||= AFMotion::Client.build('http://localhost:3000/') do
      header "Accept", "application/json"
      response_serializer :json
    end
  end

  def join_group(group, &block)
    params = { group: group, user_id: @app_delegate.user.id }

    @conn.post("happiness/join_group", params) do |result|
      process_response(result)
      block.call result
    end
  end

  def create_group(group, &block)
    params = { group: group, user_id: @app_delegate.user.id }

    @conn.post("happiness/create_group", params) do |result|
      process_response(result)
      block.call result
    end
  end

  def update_group(group, &block)
    params = { group: group, user_id: @app_delegate.user.id }

    @conn.post("happiness/update_group/#{@app_delegate.group.id}", params) do |result|
      process_response(result)
      block.call result
    end
  end

  def get_group
    params = { user_id: @app_delegate.user.id }

    @conn.post("happiness/group/#{@app_delegate.group.id}", params) do |result|
      process_response(result)
    end
  end

  def update_user_score
    params = { group_id: @app_delegate.group.id, user_id: @app_delegate.user.id, score: @app_delegate.user.score }

    @conn.post('happiness/update_user_score', params) do |result|
      process_response(result)
    end
  end

  def process_response(result)
    if result.success?
      puts "RESULT SUCCESS :) - #{result.object}"
      update_local_group(result.object['group'])
      update_local_user(result.object['user'])
    elsif result.failure?
      puts "RESULT ERROR :("
      if result.object['error']
        App.alert(result.object['error'])
      else
        App.alert("An error occurred.")
        # App.alert(result.error.localizedDescription)
      end
    end
  end

  def update_local_group(data)
    data.each do |key, value|
      @app_delegate.group.send("#{key}=", value)
    end
    @app_delegate.group.save
  end

  def update_local_user(data)
    data.each do |key, value|
      @app_delegate.user.send("#{key}=", value)
    end
    @app_delegate.user.save
  end

end