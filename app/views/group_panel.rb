class GroupPanel < UIView

  include BubbleWrap::KVO

  def initWithFrame(frame)
    super(frame)

    @app_delegate ||= UIApplication.sharedApplication.delegate
    @user ||= @app_delegate.user
    @group ||= @app_delegate.group

    add_label
    add_circle
    add_value
    add_activity_indicator
    add_user_count_label
  end

  def add_label
    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.text = group_name_label_text
    @label.textColor = Group::COLOR
    @label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 24)
    @label.numberOfLines = 0
    @label.sizeToFit
    @label.position = label_position
    @label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    @label.textAlignment = UITextAlignmentCenter

    observe(@group, :name) do |old_value, new_value|
      @label.text = group_name_label_text
      @label.sizeToFit
    end

    self.addSubview(@label)
  end

  def group_name_label_text
    if @group.id
      "#{@group.name}\nHappiness Score"
    else
      "Create or Join a Group"
    end
  end

  def add_circle
    @circle = UIView.alloc.initWithFrame(circle_frame)
    @circle.layer.cornerRadius = circle_radius
    @circle.backgroundColor = UIColor.clearColor

    self.addSubview(@circle)
  end

  def add_value
    @value = UILabel.alloc.initWithFrame(CGRectZero)
    @value.text = @group.formatted_average_score
    @value.textColor = UIColor.whiteColor
    @value.font = UIFont.fontWithName("HelveticaNeue", size: 96)
    @value.sizeToFit
    @value.position = CGPointMake(circle_radius, circle_radius)
    # @value.tag = "group_value"

    observe(@group, :average_score) do |old_value, new_value|
      @value.text = @group.formatted_average_score
      @value.sizeToFit
    end

    @circle.addSubview(@value)
  end

  def add_activity_indicator
    @indicator = UIActivityIndicatorView.alloc.initWithFrame(@value.frame)
    @indicator.color = @value.textColor
    @indicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
    @indicator.hidesWhenStopped = true
    # @indicator.tag = "group_activity_indicator"

    @circle.addSubview(@indicator)
  end

  def add_user_count_label
    @user_count_label = UILabel.alloc.initWithFrame(CGRectZero)
    @user_count_label.text = user_count_label_text
    @user_count_label.textColor = Group::COLOR
    @user_count_label.font = UIFont.fontWithName("HelveticaNeue", size: 16)
    @user_count_label.sizeToFit
    @user_count_label.position = user_count_label_position
    @user_count_label.layer.anchorPoint = CGPointMake(0.5, 0.0)
    @user_count_label.textAlignment = UITextAlignmentCenter

    observe(@group, :user_count) do |old_value, new_value|
      @user_count_label.text = user_count_label_text
    end

    self.addSubview(@user_count_label)
  end

  def circle_radius
    100
  end

  def circle_diameter
    circle_radius * 2
  end

  def mid_x
    self.size.width * 0.5
  end

  def mid_y
    self.size.height * 0.5
  end

  def label_offset_top
    self.size.height * 0.1
  end

  def label_position
    CGPointMake(mid_x, label_offset_top)
  end

  def circle_frame
    CGRectMake(mid_x - circle_radius, mid_y - circle_radius, circle_diameter, circle_diameter)
  end

  def user_count_label_position
    CGPointMake(mid_x, CGRectGetMaxY(@circle.frame) - label_offset_top)
  end

  def user_count_label_text
    if @group.user_count == 1
      "1 score"
    else
      "#{@group.user_count} scores"
    end
  end

end