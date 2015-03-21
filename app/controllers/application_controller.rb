class ApplicationController < UIViewController

  include BubbleWrap::KVO

  attr_accessor :user, :group

  def initWithUser(user, group: group)
    initWithNibName(nil, bundle:nil)
    self.user = user
    self.group = group
    self.edgesForExtendedLayout = UIRectEdgeNone

    @api_handler ||= ApiHandler.alloc.init
    @api_handler.get_average_group_score

    self
  end

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.blackColor

    user_score_label = UILabel.alloc.initWithFrame(CGRectZero)
    user_score_label.text = "Your Happiness Score"
    user_score_label.textColor = "#27D3E7".to_color # UIColor.blueColor
    user_score_label.font = UIFont.fontWithName("Copperplate", size: 28)
    user_score_label.sizeToFit
    user_score_label.position = CGPointMake(UIScreen.mainScreen.bounds.size.width * 0.5, 25)
    self.view.addSubview(user_score_label)

    user_score_circle = UIView.alloc.initWithFrame(CGRectMake(UIScreen.mainScreen.bounds.size.width * 0.5 - 100, 50, 180, 180))
    user_score_circle.layer.cornerRadius = 90
    user_score_circle.backgroundColor = "#27D3E7".to_color
    self.view.addSubview(user_score_circle)

    user_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    user_score_value.text = '%.1f' % user.score.to_f
    user_score_value.textColor = UIColor.whiteColor
    user_score_value.font = UIFont.fontWithName("Copperplate", size: 96)
    user_score_value.sizeToFit
    user_score_value.position = CGPointMake(user_score_circle.size.width * 0.5, user_score_circle.size.height * 0.5)
    user_score_circle.addSubview(user_score_value)

    user_score_increase = UIView.alloc.initWithFrame(CGRectMake(UIScreen.mainScreen.bounds.size.width * 0.5 + 120, 100, 90, 90))
    user_score_increase.backgroundColor = "#27D3E7".to_color

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointZero)
    triangle.addLineToPoint(CGPointMake(0, 90))
    triangle.addLineToPoint(CGPointMake(45, 45))
    triangle.addLineToPoint(CGPointZero)

    mask = CAShapeLayer.alloc.init
    mask.frame = user_score_increase.bounds
    mask.path = triangle.CGPath

    user_score_increase.layer.mask = mask

    user_score_increase.when_tapped do
      if user.score.round(1) < 5
        self.user.score += 0.1
        user_score_value.text = '%.1f' % user.score.to_f.round(1)
        @api_handler.set_user_score
      end
    end

    self.view.addSubview(user_score_increase)

    user_score_decrease = UIView.alloc.initWithFrame(CGRectMake(UIScreen.mainScreen.bounds.size.width * 0.5 - 220, 100, 90, 90))
    user_score_decrease.backgroundColor = "#27D3E7".to_color

    triangle = UIBezierPath.alloc.init
    triangle.moveToPoint(CGPointMake(90, 0))
    triangle.addLineToPoint(CGPointMake(45, 45))
    triangle.addLineToPoint(CGPointMake(90, 90))
    triangle.addLineToPoint(CGPointMake(90, 0))

    mask = CAShapeLayer.alloc.init
    mask.frame = user_score_decrease.bounds
    mask.path = triangle.CGPath

    user_score_decrease.layer.mask = mask

    user_score_decrease.when_tapped do
      if user.score.round(1) > 0
        self.user.score -= 0.1
        user_score_value.text = '%.1f' % (user.score.to_f.round(1) + 0) # Adding zero fixes the -0.0 problem - weird!
        @api_handler.set_user_score
      end
    end

    self.view.addSubview(user_score_decrease)

    line = UIView.alloc.initWithFrame(CGRectMake(0, UIScreen.mainScreen.bounds.size.height * 0.5, UIScreen.mainScreen.bounds.size.width, 1))
    line.backgroundColor = UIColor.whiteColor
    self.view.addSubview(line)

    # ------------- group score --------------


    group_score_label = UILabel.alloc.initWithFrame(CGRectZero)
    group_score_label.text = "Hooroo Happiness Score"
    group_score_label.textColor = "#06BF40".to_color # UIColor.blueColor
    group_score_label.font = UIFont.fontWithName("Copperplate", size: 28)
    group_score_label.sizeToFit
    group_score_label.position = CGPointMake(UIScreen.mainScreen.bounds.size.width * 0.5, 25 + UIScreen.mainScreen.bounds.size.height * 0.5)
    self.view.addSubview(group_score_label)

    group_score_circle = UIView.alloc.initWithFrame(CGRectMake(UIScreen.mainScreen.bounds.size.width * 0.5 - 100, 50 + UIScreen.mainScreen.bounds.size.height * 0.5, 180, 180))
    group_score_circle.layer.cornerRadius = 90
    group_score_circle.backgroundColor = "#06BF40".to_color
    self.view.addSubview(group_score_circle)

    group_score_value = UILabel.alloc.initWithFrame(CGRectZero)
    group_score_value.text = '%.1f' % group.score.to_f
    group_score_value.textColor = UIColor.whiteColor
    group_score_value.font = UIFont.fontWithName("Copperplate", size: 96)
    group_score_value.sizeToFit
    group_score_value.position = CGPointMake(group_score_circle.size.width * 0.5, group_score_circle.size.height * 0.5)

    observe(self.group, :score) do |old_value, new_value|
      group_score_value.text = '%.1f' % new_value
      group_score_value.sizeToFit
    end

    group_score_circle.addSubview(group_score_value)
  end

end