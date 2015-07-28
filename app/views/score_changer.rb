class ScoreChanger < UIView

  include ViewTags

  COLOR = "#FFFF19".to_color

  def initWithFrame(frame, shape: shape, interval_modifier: interval_modifier)
    self.initWithFrame(frame)

    @app_delegate ||= UIApplication.sharedApplication.delegate
    @group = @app_delegate.group
    @score = @app_delegate.score

    @shape = shape
    @interval_modifier = interval_modifier

    set_background
    set_tap_action

    self
  end


  private

  attr_reader :group, :score, :shape, :interval_modifier

  def set_background
    self.backgroundColor = ScoreChanger::COLOR
    self.layer.opacity = 0.8
    self.layer.mask = create_mask
  end

  def set_tap_action
    self.when_tapped do
      next unless group.loaded?

      score = calculate_new_score
      next unless group.score_in_range?(score)

      update_local_score(score)
      animate_score_change
      group_panel.show_activity_indicator

      @last_tapped = Time.now

      App.run_after(score_change_delay) do
        if time_since_last_tapped >= score_change_delay
          ApiHandler.alloc.init.update_score  do |result|
            group_panel.hide_activity_indicator
          end
        end
      end
    end
  end

  def calculate_new_score
    score.score.to_f + (group.interval.to_f * interval_modifier)
  end

  def create_mask
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

  def group_panel
    self.superview.superview.viewWithTag(ViewTags::GROUP_PANEL)
  end

  def update_local_score(new_score)
    score.score = new_score.round(1) + 0.0 # the +0.0 fixes weird float bug when score is set to zero
    score.save
  end

  def time_since_last_tapped
    Time.now - @last_tapped
  end

  def score_change_delay
    0.5
  end

end