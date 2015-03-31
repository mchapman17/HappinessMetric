class ApplicationController < UIViewController

  include BubbleWrap::KVO

  attr_accessor :user, :group

  def initWithUser(user, group: group, api_handler: api_handler)
    initWithNibName(nil, bundle:nil)
    @user = user
    @group = group
    @api_handler = api_handler

    self.title = 'Happiness Metric'
    self.edgesForExtendedLayout = UIRectEdgeNone
    self
  end

  def viewDidLoad
    super

    add_background
    add_group_settings_button

    add_user_panel
    add_user_score_label
    add_user_score_circle
    add_user_score_value
    add_user_score_increaser
    add_user_score_decreaser

    add_separator

    add_group_panel
    add_group_average_score_label
    add_group_average_score_circle
    add_group_average_score_value
    add_group_average_score_activity
    add_group_user_count_label
  end

  def add_background
    background = UIImageView.alloc.initWithImage(UIImage.imageNamed('background.png'))
    self.view.addSubview(background)
  end

  def add_group_settings_button
    button = UIBarButtonItem.alloc.initWithTitle("Settings",
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: 'show_group_settings')
    self.navigationItem.rightBarButtonItem = button
  end

  def show_group_settings
    @group_settings_controller ||= GroupSettingsController.alloc.initWithGroup(@group)
    self.navigationController.pushViewController(@group_settings_controller, animated: true)
  end

  def add_user_panel
    @user_panel = UIView.alloc.initWithFrame(user_panel_frame)
    self.view.addSubview(@user_panel)
  end

  def add_user_score_label
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = "Your Happiness Score"
    label.textColor = Group::COLOR # UIColor.whiteColor # User::COLOR
    label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 24)
    label.sizeToFit
    label.position = CGPointMake(user_panel_mid_x, user_score_label_offset_top)
    label.textAlignment = UITextAlignmentCenter

    @user_panel.addSubview(label)
  end

  def add_user_score_circle
    @user_score_circle = UIView.alloc.initWithFrame(user_score_circle_frame)
    @user_score_circle.backgroundColor = UIColor.darkGrayColor.colorWithAlphaComponent(0.5) # User::COLOR
    @user_score_circle.layer.cornerRadius = circle_radius

    @user_panel.addSubview(@user_score_circle)
  end

  def add_user_score_value
    @user_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    @user_score_value.text = format_user_score(@user.score)
    @user_score_value.textColor = UIColor.whiteColor
    @user_score_value.font = UIFont.fontWithName("HelveticaNeue", size: 84)
    @user_score_value.sizeToFit
    @user_score_value.position = CGPointMake(circle_radius, circle_radius)

    @user_score_circle.addSubview(@user_score_value)
  end

  def update_user_score_value
    @user_score_value.text = format_user_score(@user.score)
  end

  def add_user_score_increaser
    increaser = UIView.alloc.initWithFrame(score_increaser_frame)
    increaser.backgroundColor = "#FFFF19".to_color  # User::COLOR
    increaser.layer.opacity = 0.8

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointZero)
    triangle.addLineToPoint(CGPointMake(0, circle_radius * 0.5))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.25, circle_radius * 0.25))
    triangle.addLineToPoint(CGPointZero)

    mask = CAShapeLayer.alloc.init
    mask.frame = increaser.bounds
    mask.path = triangle.CGPath
    increaser.layer.mask = mask

    increaser.when_tapped do
      next if @user.score >= @group.max_score

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

    @user_panel.addSubview(increaser)
  end

  def add_user_score_decreaser
    decreaser = UIView.alloc.initWithFrame(score_decreaser_frame)
    decreaser.backgroundColor = "#FFFF19".to_color  # User::COLOR
    decreaser.layer.opacity = 0.8

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointMake(circle_radius * 0.5, 0))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.25, circle_radius * 0.25))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.5, circle_radius * 0.5))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.5, 0))

    mask = CAShapeLayer.alloc.init
    mask.frame = decreaser.bounds
    mask.path = triangle.CGPath
    decreaser.layer.mask = mask

    decreaser.when_tapped do
      puts "user: #{@user.score.round(1)}  min: #{@group.min_score}"
      next if @user.score.round(1) <= @group.min_score

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

    @user_panel.addSubview(decreaser)
  end

  def animate_score_change(view)
    offset = 2
    UIView.animateWithDuration(0.1,
      animations: -> {
        view.position = CGPointMake(view.position.x + offset, view.position.y + offset)
        view.alpha = 0.6
      },
      completion: -> finished {
        view.position = CGPointMake(view.position.x - offset, view.position.y - offset)
        view.alpha = 0.8
      }
    )
  end

  def user_score_change_delay
    0.5
  end

  def add_separator
    @separator = UIView.alloc.initWithFrame(CGRectMake(0, user_panel_height, screen_width, 1))
    @separator.backgroundColor = UIColor.whiteColor

    self.view.addSubview(@separator)
  end

  def add_group_panel
    @group_panel = UIView.alloc.initWithFrame(group_panel_frame)
    self.view.addSubview(@group_panel)
  end

  def add_group_average_score_label
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = group_name_label_text
    label.textColor = Group::COLOR
    label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 24)
    label.numberOfLines = 0
    label.sizeToFit
    label.position = group_average_score_label_position
    label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    label.textAlignment = UITextAlignmentCenter

    observe(@group, :name) do |old_value, new_value|
      label.text = group_name_label_text
      label.sizeToFit
    end

    @group_panel.addSubview(label)
  end

  def group_name_label_text
    "#{@group.name}\nHappiness Score"
  end

  def add_group_average_score_circle
    @group_average_score_circle = UIView.alloc.initWithFrame(group_average_score_circle_frame)
    @group_average_score_circle.layer.cornerRadius = circle_radius
    @group_average_score_circle.backgroundColor = UIColor.clearColor # Group::COLOR

    @group_panel.addSubview(@group_average_score_circle)
  end

  def add_group_average_score_value
    @group_average_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    @group_average_score_value.text = format_group_score(@group.average_score)
    @group_average_score_value.textColor = UIColor.whiteColor
    @group_average_score_value.font = UIFont.fontWithName("HelveticaNeue", size: 96)
    @group_average_score_value.sizeToFit
    @group_average_score_value.position = CGPointMake(circle_radius, circle_radius)

    observe(@group, :average_score) do |old_value, new_value|
      @group_average_score_value.text = format_group_score(new_value)
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
    label.font = UIFont.fontWithName("HelveticaNeue", size: 18)
    label.sizeToFit
    label.position = group_user_count_label_position
    label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    label.textAlignment = UITextAlignmentCenter

    observe(@group, :user_count) do |old_value, new_value|
      label.text = group_user_count_label_text
    end

    @group_panel.addSubview(label)
  end

  def group_user_count_label_position
    CGPointMake(group_panel_mid_x, CGRectGetMaxY(@group_average_score_circle.frame) + group_score_label_offset_top)
  end

  def group_user_count_label_text
    "Users: #{@group.user_count}"
  end

  def change_user_score_by(amount)
    @user.score = @user.score.round(1) + amount + 0.0 # the + 0.0 fixes weird float bug when score is set to zero
    @user.save
    update_user_score_value
  end

  def format_user_score(score)
    '%.1f' % score.to_f
  end

  def format_group_score(score)
    '%.2f' % score.to_f
  end

  def screen_width
    UIScreen.mainScreen.applicationFrame.size.width
  end

  def screen_width_middle
    screen_width * 0.5
  end

  def screen_height
    UIScreen.mainScreen.applicationFrame.size.height
  end

  def screen_height_middle
    screen_height * 0.5
  end

  def user_panel_frame
    CGRectMake(0, 0, user_panel_width, user_panel_height)
  end

  def user_panel_width
    screen_width
  end

  def user_panel_height
    screen_height * 0.5
  end

  def user_panel_mid_x
    user_panel_width * 0.5
  end

  def user_panel_mid_y
    user_panel_height * 0.5
  end

  def user_score_label_offset_top
    user_panel_height * 0.1
  end

  def user_score_circle_frame
    CGRectMake(user_panel_mid_x - circle_radius, user_panel_mid_y - circle_radius, circle_diameter, circle_diameter)
  end

  def group_panel_frame
    CGRectMake(0, user_panel_height, group_panel_width, group_panel_height)
  end

  def group_panel_width
    screen_width
  end

  def group_panel_height
    screen_height - user_panel_height
  end

  def group_panel_mid_x
    group_panel_width * 0.5
  end

  def group_panel_mid_y
    group_panel_height * 0.5
  end

  def group_score_label_offset_top
    group_panel_height * 0.1
  end

  def circle_radius
    100
  end

  def circle_diameter
    circle_radius * 2
  end

  def score_increaser_frame
    CGRectMake(
      user_panel_mid_x + score_changer_offset_center,
      user_panel_mid_y - circle_radius * 0.25,
      circle_radius * 0.5,
      circle_radius * 0.5
    )
  end

  def score_decreaser_frame
    CGRectMake(
      user_panel_mid_x - score_changer_offset_center - circle_radius * 0.5,
      user_panel_mid_y - circle_radius * 0.25,
      circle_radius * 0.5,
      circle_radius * 0.5
    )
  end

  def score_changer_offset_center
    circle_radius * 1.2
  end

  def group_average_score_label_position
    CGPointMake(group_panel_mid_x, group_score_label_offset_top)
  end

  def group_average_score_circle_frame
    CGRectMake(
      group_panel_mid_x - circle_radius,
      group_panel_mid_y - circle_radius,
      circle_diameter,
      circle_diameter
    )
  end

  def separator_y
    CGRectGetMidY(@separator.bounds)
  end

end