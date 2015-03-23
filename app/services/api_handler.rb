class ApiHandler

  def initialize
    @app_delegate ||= UIApplication.sharedApplication.delegate
    @conn ||= AFMotion::Client.build('http://localhost:3000/') do
      header "Accept", "application/json"
      response_serializer :json
    end
  end

  def get_group_average_score
    @conn.get("happiness/group_average_score/#{@app_delegate.group.id}") do |result|
      process_response(result)
    end
  end

  def set_user_score
    params = { group_id: @app_delegate.group.id, user_id: @app_delegate.user.id, score: @app_delegate.user.score }
    @conn.post('happiness/user_score', params) do |result|
      process_response(result)
    end
  end

  def process_response(result)
    if result.success?
      @app_delegate.group.average_score = result.object["group_average_score"]
      @app_delegate.group.user_count = result.object["group_user_count"]
    elsif result.operation.response.statusCode.to_s =~ /40\d/
      App.alert("Group score update failed.")
    elsif result.failure?
      App.alert(result.error.localizedDescription)
    end
  end


end