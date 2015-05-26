# this is a workaround to give the ability to style Formotion controls
module Formotion
  class Form < Formotion::Base
    def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
      # cell.textLabel.textColor = UIColor.greenColor
    end
  end
end


class JoinCreateGroupController < Formotion::FormController

  def init
    self.title = "Join/Create"
    self.initWithForm(create_form)
    self.view.backgroundColor = UIColor.whiteColor

    # seems to be the only way to style the form currently in Formotion
    self.form.instance_eval do
      def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        if submit_button?(cell)
          cell.textColor = UIColor.whiteColor
          cell.contentView.backgroundColor = Group::COLOR
        end
      end

      def submit_button?(cell)
        ["Join Group", "Create Group"].include?(cell.text)
      end
    end

    self
  end

  def viewDidLoad
    super

    # add_background
  end

  def add_background
    background = UIImageView.alloc.initWithImage(UIImage.imageNamed('background.png'))
    self.view.addSubview(background)
  end

  def create_form
    @form = Formotion::Form.new

    @form.build_section do |section|
      section.title = "Join Group"
      section.build_row do |row|
        row.title = "Name"
        row.key = :join_name
        row.placeholder = "Group Name"
        row.type = :string
        row.auto_correction = :no
      end

      section.build_row do |row|
        row.title = "Password"
        row.key = :join_password
        row.placeholder = "required"
        row.type = :string
        row.secure = true
      end

      section.build_row do |row|
        row.title = "Join Group"
        row.type = :button

        row.on_tap { |_| join_group }
      end
    end

    @form.build_section do |section|
      section.title = "Create Group"
      section.build_row do |row|
        row.title = "Name"
        row.key = :create_name
        row.placeholder = "Group Name"
        row.type = :string
        row.auto_correction = :no
      end

      section.build_row do |row|
        row.title = "Password"
        row.key = :create_password
        row.placeholder = "required"
        row.type = :string
        row.secure = true
      end

      section.build_row do |row|
        row.title = "Password"
        row.subtitle = "Confirm"
        row.key = :create_password_confirm
        row.placeholder = "required"
        row.type = :string
        row.secure = true
      end

      section.build_row do |row|
        row.title = "Create Group"
        row.type = :button

        row.on_tap { |_| create_group }
      end
    end

    @form
  end

  def join_group
    data = @form.render
    if ApiHandler.alloc.init.join_group(data[:join_name], data[:join_password])
      puts "---- Joined #{data[:join_name]}!"
      self.dismissViewControllerAnimated(true, completion: nil)
    else
      puts "---- didn't Join #{data[:join_name]}!"
    end
  end

  def create_group
    data = @form.render
    raise "Passwords don't match." if data[:create_password] != data[:create_password_confirm]
    ApiHandler.alloc.init.create_group(data[:create_name], data[:create_password])
  end

end





