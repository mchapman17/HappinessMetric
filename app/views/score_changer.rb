class ScoreChanger < UIView

  def initWithFrame(frame, shape: shape, interval: interval)
    self.initWithFrame(frame)

    @app_delegate ||= UIApplication.sharedApplication.delegate
    @user ||= @app_delegate.user
    @group ||= @app_delegate.group

    self.backgroundColor = "#FFFF19".to_color
    self.layer.opacity = 0.8

    mask = CAShapeLayer.alloc.init
    mask.frame = self.bounds
    mask.path = shape.CGPath
    self.layer.mask = mask

    self.when_tapped do
      score = @user.score + interval
      next if score_out_of_range?(score)

      animate_score_change
      update_user_score(score)

      # @group_average_score_value.hidden = true
      # @group_average_score_activity.startAnimating

      @last_tapped = Time.now

      App.run_after(score_change_delay) do
        if Time.now - @last_tapped >= score_change_delay
          ApiHandler.alloc.init.set_user_score
          # App.run_after(0.1) do
          #   @group_average_score_activity.stopAnimating
          #   @group_average_score_value.hidden = false
          # end
        end
      end
    end

    self
  end

  def animate_score_change
    position_offset = 2

    UIView.animateWithDuration(0.1,
      animations: -> {
        self.position = CGPointMake(self.position.x + position_offset, self.position.y + position_offset)
        self.alpha = 0.6
      },
      completion: -> finished {
        self.position = CGPointMake(self.position.x - position_offset, self.position.y - position_offset)
        self.alpha = 0.8
      }
    )
  end

  def update_user_score(score)
    @user.score = score.round(1) + 0.0 # the + 0.0 fixes weird float bug when score is set to zero
    @user.save
  end

  def score_out_of_range?(score)
    puts "score: #{score.round(1)} min: #{@group.min_score} max: #{@group.max_score} result: #{score.round(1) < @group.min_score || score.round(1) > @group.max_score}"
    score.round(1) < @group.min_score || score.round(1) > @group.max_score
  end

  def score_change_delay
    0.5
  end

end