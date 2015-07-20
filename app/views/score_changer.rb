class ScoreChanger < UIView

  include ViewTags

  def initWithFrame(frame, shape: shape, interval_modifier: interval_modifier)
    self.initWithFrame(frame)

    @app_delegate ||= UIApplication.sharedApplication.delegate
    @group = @app_delegate.group
    @score = @app_delegate.score

    self.backgroundColor = "#FFFF19".to_color
    self.layer.opacity = 0.8
    self.layer.mask = create_mask(shape)

    self.when_tapped do
      next unless @group.loaded?

      interval = @group.interval.to_f * interval_modifier.to_f
      score = @score.score.to_f + interval
      next if @group.score_out_of_range?(score)

      animate_score_change
      update_local_score(score)

      indicator = self.superview.superview.viewWithTag(ViewTags::INDICATOR)
      group_value = self.superview.superview.viewWithTag(ViewTags::GROUP_VALUE)

      group_value.hidden = true
      indicator.startAnimating

      @last_tapped = Time.now

      App.run_after(score_change_delay) do
        if time_since_last_tapped >= score_change_delay
          ApiHandler.alloc.init.update_score
          App.run_after(0.1) do
            indicator.stopAnimating
            group_value.hidden = false
          end
        end
      end
    end

    self
  end

  def create_mask(shape)
    CAShapeLayer.alloc.init.tap do |mask|
      mask.frame = self.bounds
      mask.path = shape.CGPath
    end
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

  def update_local_score(score)
    @score.score = score.round(1) + 0.0 # the +0.0 fixes weird float bug when score is set to zero
    @score.save
  end

  def time_since_last_tapped
    Time.now - @last_tapped
  end

  def score_change_delay
    0.5
  end

end