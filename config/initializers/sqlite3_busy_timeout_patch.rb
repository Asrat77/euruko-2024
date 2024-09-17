# SQLite3::Database#busy_timeout(ms) is a method that sets the `busy_timeout` PRAGMA.
# In the context of Rails applications, this pragma causes problems, because
# the SQLite C method doesn't release Ruby's GVL, which can cause the entire
# application to hang. While the `sqlite3-ruby` gem provides an alternative
# with the `busy_handler_timeout=` method, Rails < 8.0.0 doesn't use it. Rails
# < 8.0.0 uses the `busy_timeout(ms)` method. This monkey patch replaces the
# implementation of `busy_timeout(ms)` to instead forward the call to
# `busy_handler_timeout=(ms)`. This way, the `busy_handler_timeout=(ms)` method is
# used instead of the `busy_timeout(ms)` method, which should prevent the
# application from hanging.
#
# This patch assumes the #busy_timeout=(ms) method exists on
# SQLite3::Database and accepts one argument.
#
module SQLiteBusyTimeoutMonkeypatch
  class << self
    def apply_patch
      # Rails >= 8.0.0 doesn't need this patch, since it calls the
      # `busy_handler_timeout=` method directly.
      # This patch is only necessary for Rails < 8.0.0.
      return if Rails::VERSION::MAJOR == 8

      # make sure the class we want to patch exists
      const = find_const_to_patch
      raise "Could not find class to patch" if const.nil?

      # make sure the #busy_timeout method exists and accepts one argument
      mtd = find_method_to_patch(const)
      raise "Could not find method to patch" if mtd.nil? || mtd.arity != 1

      # make sure the #busy_handler_timeout method exists and accepts one argument
      dlg = find_method_for_patch(const)
      raise "Could not find method for patch" if dlg.nil? || dlg.arity != 1

      # actually apply the patch
      const.prepend(InstanceMethods)
    end

    private

    def find_const_to_patch
      Kernel.const_get('SQLite3::Database')
    rescue NameError
      # return nil if the constant doesn't exist
    end

    def find_method_to_patch(const)
      return unless const
      const.instance_method(:busy_timeout)
    rescue NameError
      # return nil if the method doesn't exist
    end

    def find_method_for_patch(const)
      return unless const
      const.instance_method(:busy_handler_timeout=)
    rescue NameError
      # return nil if the method doesn't exist
    end
  end

  module InstanceMethods
    # forward the call to `busy_handler_timeout`
    def busy_timeout(milliseconds)
      self.busy_handler_timeout = milliseconds
    end
  end
end

SQLiteBusyTimeoutMonkeypatch.apply_patch
