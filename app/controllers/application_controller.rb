class ApplicationController < UIViewController

  include BubbleWrap::KVO

  attr_accessor :user, :group

  def initWithUser(user, group: group, api_handler: api_handler)
    initWithNibName(nil, bundle:nil)
    @user = user
    @group = group
    @api_handler = api_handler

    self.edgesForExtendedLayout = UIRectEdgeNone
    self
  end

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.blackColor

    add_user_score_label
    add_user_score_circle
    add_user_score_value
    add_user_score_increaser
    add_user_score_decreaser

    add_separator

    add_group_average_score_label
    add_group_average_score_circle
    add_group_average_score_value
    add_group_average_score_activity
    add_group_user_count_label
  end

  def add_user_score_label
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = "Your Happiness Score"
    label.textColor = User::COLOR
    label.font = UIFont.fontWithName("Copperplate", size: 28)
    label.sizeToFit
    label.position = CGPointMake(screen_width_middle, score_label_offset_top)
    label.textAlignment = UITextAlignmentCenter

    self.view.addSubview(label)
  end

  def add_user_score_circle
    @user_score_circle = UIView.alloc.initWithFrame(user_score_circle_frame)
    @user_score_circle.layer.cornerRadius = circle_radius
    @user_score_circle.backgroundColor = User::COLOR

    self.view.addSubview(@user_score_circle)
  end

  def add_user_score_value
    @user_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    @user_score_value.text = format_score(@user.score)
    @user_score_value.textColor = UIColor.whiteColor
    @user_score_value.font = UIFont.fontWithName("Copperplate", size: 96)
    @user_score_value.sizeToFit
    @user_score_value.position = CGPointMake(circle_radius, circle_radius)

    @user_score_circle.addSubview(@user_score_value)
  end

  def update_user_score_value
    @user_score_value.text = format_score(@user.score)
  end

  def add_user_score_increaser
    increaser = UIView.alloc.initWithFrame(score_increaser_frame)
    increaser.backgroundColor = User::COLOR

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointZero)
    triangle.addLineToPoint(CGPointMake(0, circle_radius))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.5, circle_radius * 0.5))
    triangle.addLineToPoint(CGPointZero)

    mask = CAShapeLayer.alloc.init
    mask.frame = increaser.bounds
    mask.path = triangle.CGPath
    increaser.layer.mask = mask

    increaser.when_tapped do
      @increaser_tapped = Time.now

      animate_score_change(increaser)
      change_user_score_by(@group.interval)

      @group_average_score_value.hidden = true
      @group_average_score_activity.startAnimating

      App.run_after(user_score_change_delay) do
        if Time.now - @increaser_tapped >= user_score_change_delay
          @api_handler.set_user_score
          App.run_after(0.1) do
            @group_average_score_activity.stopAnimating
            @group_average_score_value.hidden = false
          end
        end
      end
    end

    self.view.addSubview(increaser)
  end

  def add_user_score_decreaser
    decreaser = UIView.alloc.initWithFrame(score_decreaser_frame)
    decreaser.backgroundColor = User::COLOR

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointMake(90, 0))
    triangle.addLineToPoint(CGPointMake(45, 45))
    triangle.addLineToPoint(CGPointMake(90, 90))
    triangle.addLineToPoint(CGPointMake(90, 0))

    mask = CAShapeLayer.alloc.init
    mask.frame = decreaser.bounds
    mask.path = triangle.CGPath
    decreaser.layer.mask = mask

    decreaser.when_tapped do
      @decreaser_tapped = Time.now

      animate_score_change(decreaser)
      change_user_score_by(-@group.interval)

      @group_average_score_value.hidden = true
      @group_average_score_activity.startAnimating

      App.run_after(user_score_change_delay) do
        if Time.now - @decreaser_tapped >= user_score_change_delay
          @api_handler.set_user_score
          App.run_after(0.1) do
            @group_average_score_activity.stopAnimating
            @group_average_score_value.hidden = false
          end
        end
      end
    end

    self.view.addSubview(decreaser)
  end

  def animate_score_change(view)
    offset = 4
    UIView.animateWithDuration(0.05,
      animations: -> {
        view.position = CGPointMake(view.position.x + offset, view.position.y + offset)
        view.alpha = 0.7
      },
      completion: -> finished {
        view.position = CGPointMake(view.position.x - offset, view.position.y - offset)
        view.alpha = 1.0
      }
    )
  end

  def user_score_change_delay
    0.5
  end

  def add_separator
    line = UIView.alloc.initWithFrame(CGRectMake(0, screen_height_middle - separator_offset_bottom, screen_width, 1))
    line.backgroundColor = UIColor.whiteColor

    self.view.addSubview(line)
  end

  def add_group_average_score_label
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = "#{@group.name}\nHappiness Score"
    label.textColor = Group::COLOR
    label.font = UIFont.fontWithName("Copperplate", size: 28)
    label.numberOfLines = 0
    label.sizeToFit
    label.position = CGPointMake(screen_width_middle, screen_height_middle + score_label_offset_top - separator_offset_bottom)
    label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    label.textAlignment = UITextAlignmentCenter

    self.view.addSubview(label)
  end

  def add_group_average_score_circle
    @group_average_score_circle = UIView.alloc.initWithFrame(group_average_score_circle_frame)
    @group_average_score_circle.layer.cornerRadius = circle_radius
    @group_average_score_circle.backgroundColor = Group::COLOR

    self.view.addSubview(@group_average_score_circle)
  end

  def add_group_average_score_value
    @group_average_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    @group_average_score_value.text = format_score(@group.average_score)
    @group_average_score_value.textColor = UIColor.whiteColor
    @group_average_score_value.font = UIFont.fontWithName("Copperplate", size: 96)
    @group_average_score_value.sizeToFit
    @group_average_score_value.position = CGPointMake(circle_radius, circle_radius)

    observe(@group, :average_score) do |old_value, new_value|
      @group_average_score_value.text = format_score(new_value)
      @group_average_score_value.sizeToFit
    end

    @group_average_score_circle.addSubview(@group_average_score_value)
  end

  def add_group_average_score_activity
    @group_average_score_activity = UIActivityIndicatorView.alloc.initWithFrame(@group_average_score_value.frame)
    @group_average_score_activity.color = @group_average_score_value.textColor
    @group_average_score_activity.transform = CGAffineTransformMakeScale(2.0, 2.0)
    @group_average_score_activity.hidesWhenStopped = true

    @group_average_score_circle.addSubview(@group_average_score_activity)
  end

  def add_group_user_count_label
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = group_user_count_label_text
    label.textColor = Group::COLOR
    label.font = UIFont.fontWithName("Copperplate", size: 18)
    label.sizeToFit
    label.position = CGPointMake(screen_width_middle, CGRectGetMaxY(@group_average_score_circle.frame) + score_label_offset_top)
    label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    label.textAlignment = UITextAlignmentCenter

    observe(@group, :user_count) do |old_value, new_value|
      label.text = group_user_count_label_text # new_value.to_s
      label.sizeToFit
    end

    self.view.addSubview(label)
  end

  def group_user_count_label_text
    "Users: #{@group.user_count}"
  end

  def change_user_score_by(amount)
    score = @user.score.round(1) + amount

    if user_score_in_range?(score)
      @user.score = score
      @user.save
      update_user_score_value
    end
  end

  def user_score_in_range?(score)
    score >= @group.min_score && score <= @group.max_score
  end

  def format_score(score)
    '%.1f' % score.to_f
  end

  def screen_width
    UIScreen.mainScreen.bounds.size.width
  end

  def screen_width_middle
    screen_width * 0.5
  end

  def screen_height
    UIScreen.mainScreen.bounds.size.height
  end

  def screen_height_middle
    screen_height * 0.5
  end

  def score_label_offset_top
    20
  end

  def user_score_circle_frame
    CGRectMake(screen_width_middle - circle_radius, circle_offset_top, circle_diameter, circle_diameter)
  end

  def circle_radius
    90
  end

  def circle_diameter
    circle_radius * 2
  end

  def circle_offset_top
    50
  end

  def score_increaser_frame
    CGRectMake(screen_width_middle + score_changer_offset_center, circle_radius, circle_radius, circle_radius)
  end

  def score_decreaser_frame
    CGRectMake(screen_width_middle - score_changer_offset_center - circle_radius, circle_radius, circle_radius, circle_radius)
  end

  def score_changer_offset_center
    110
  end

  def separator_offset_bottom
    80
  end

  def group_average_score_circle_frame
    CGRectMake(screen_width_middle - circle_radius, screen_height_middle + circle_offset_top + circle_offset_top - separator_offset_bottom, circle_diameter, circle_diameter)
  end

end