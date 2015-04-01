class UserPanel < UIView

  include BubbleWrap::KVO

  def initWithFrame(frame)
    super(frame)

    @app_delegate ||= UIApplication.sharedApplication.delegate
    @user ||= @app_delegate.user
    @group ||= @app_delegate.group

    add_label
    add_circle
    add_value
    add_increaser
    add_decreaser
  end


  private

  def add_label
    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.text = "Your Happiness Score"
    @label.textColor = Group::COLOR
    @label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 24)
    @label.sizeToFit
    @label.position = CGPointMake(mid_x, label_offset_top)
    @label.textAlignment = UITextAlignmentCenter

    self.addSubview(@label)
  end

  def add_circle
    @circle = UIView.alloc.initWithFrame(circle_frame)
    @circle.backgroundColor = UIColor.darkGrayColor.colorWithAlphaComponent(0.5)
    @circle.layer.cornerRadius = circle_radius

    self.addSubview(@circle)
  end

  def add_value
    @value = UILabel.alloc.initWithFrame(CGRectZero)
    @value.text = @user.formatted_score
    @value.textColor = UIColor.whiteColor
    @value.font = UIFont.fontWithName("HelveticaNeue", size: 84)
    @value.sizeToFit
    @value.position = CGPointMake(circle_radius, circle_radius)

    observe(@user, :score) do |old_value, new_value|
      @value.text = @user.formatted_score
      @value.sizeToFit
    end

    @circle.addSubview(@value)
  end

  def add_increaser
    increaser = ScoreChanger.alloc.initWithFrame(increaser_frame, shape: increaser_shape, interval: @group.interval)
    self.addSubview(increaser)
  end

  def add_decreaser
    decreaser = ScoreChanger.alloc.initWithFrame(decreaser_frame, shape: decreaser_shape, interval: -@group.interval)
    self.addSubview(decreaser)
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

  def circle_frame
    CGRectMake(mid_x - circle_radius, mid_y - circle_radius, circle_diameter, circle_diameter)
  end

  def increaser_frame
    CGRectMake(mid_x + score_changer_offset_center, mid_y - circle_radius * 0.25, circle_radius * 0.5, circle_radius * 0.5)
  end

  def increaser_shape
    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointZero)
    triangle.addLineToPoint(CGPointMake(0, circle_radius * 0.5))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.25, circle_radius * 0.25))
    triangle.addLineToPoint(CGPointZero)
    triangle
  end

  def decreaser_frame
    CGRectMake(mid_x - score_changer_offset_center - circle_radius * 0.5, mid_y - circle_radius * 0.25, circle_radius * 0.5,         circle_radius * 0.5)
  end

  def decreaser_shape
    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointMake(circle_radius * 0.5, 0))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.25, circle_radius * 0.25))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.5, circle_radius * 0.5))
    triangle.addLineToPoint(CGPointMake(circle_radius * 0.5, 0))
    triangle
  end

  def score_changer_offset_center
    circle_radius * 1.2
  end

end