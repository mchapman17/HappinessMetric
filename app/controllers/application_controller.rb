class ApplicationController < UIViewController

  attr_accessor :user, :group, :score

  def initWithUser(user, group: group, score: score)
    initWithNibName(nil, bundle: nil)
    @user = user
    @group = group
    @score = score

    self.title = 'Happiness Metric'
    self.edgesForExtendedLayout = UIRectEdgeNone
    self
  end

  def viewDidLoad
    super

    add_background
    add_join_create_group_button
    add_group_settings_button

    add_user_panel
    add_separator
    add_group_panel

    if @group.id
      ApiHandler.alloc.init.show_group
    end
  end

  def add_background
    background = UIImageView.alloc.initWithImage(UIImage.imageNamed('background.png'))
    self.view.addSubview(background)
  end

  def add_join_create_group_button
    button = UIBarButtonItem.alloc.initWithTitle("Join/Create",
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: 'show_join_create_group')
    self.navigationItem.leftBarButtonItem = button
  end

  def show_join_create_group
    @join_create_group_controller ||= JoinCreateGroupController.alloc.init
    self.navigationController.pushViewController(@join_create_group_controller, animated: true)
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
    @user_panel = UserPanel.alloc.initWithFrame(user_panel_frame)
    self.view.addSubview(@user_panel)
  end

  def add_separator
    @separator = UIView.alloc.initWithFrame(CGRectMake(0, user_panel_height, screen_width, 1))
    @separator.backgroundColor = UIColor.whiteColor

    self.view.addSubview(@separator)
  end

  def add_group_panel
    @group_panel = GroupPanel.alloc.initWithFrame(group_panel_frame)
    self.view.addSubview(@group_panel)
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

  def group_panel_frame
    CGRectMake(0, user_panel_height, group_panel_width, group_panel_height)
  end

  def group_panel_width
    screen_width
  end

  def group_panel_height
    screen_height - user_panel_height
  end

end