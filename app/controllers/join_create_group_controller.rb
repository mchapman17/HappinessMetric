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
  end

  def create_form
    @form = Formotion::Form.new

    @form.build_section do |section|
      section.title = "Join Group"
      section.build_row do |row|
        row.title = "Name"
        row.key = :join_name
        row.placeholder = "required"
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
        row.placeholder = "required"
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
    params = { name: data[:join_name], password: data[:join_password] }

    ApiHandler.alloc.init.join_group(params) do |result|
      if result.success?
        self.navigationController.popViewControllerAnimated(true)
        reset_form_values
      end
    end
  end

  def create_group
    data = @form.render
    params = { name: data[:create_name], password: data[:create_password] }

    # client-side validation - raise "Passwords don't match." if data[:create_password] != data[:create_password_confirm]

    ApiHandler.alloc.init.create_group(params) do |result|
      if result.success?
        self.navigationController.popViewControllerAnimated(true)
        reset_form_values
      end
    end
  end


  private

  def reset_form_values
    @form.values = {
      join_name: nil,
      join_password: nil,
      create_name: nil,
      create_password: nil,
      create_password_confirm: nil
    }
  end

end





