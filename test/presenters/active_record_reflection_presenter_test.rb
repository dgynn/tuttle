require 'test_helper'
require 'tuttle/presenters/active_record/reflection_presenter'

module Tuttle
  class ActiveRecordReflectionPresenter < ActionView::TestCase
    helper ::Tuttle::Engine.helpers

    def test_user_has_many_notes
      # Setup
      user_notes_association = User.reflect_on_association(:notes)
      presenter = ::Tuttle::Presenters::ActiveRecord::ReflectionPresenter.new(user_notes_association, view)

      # Delegated methods
      assert_equal :notes.inspect, presenter.name
      assert_equal :has_many.inspect, presenter.macro
      assert_nil presenter.type
      assert_equal "user_id", presenter.foreign_key

      # Presenter Methods
      assert_equal "<span class=\"autodetected\">:user</span>", presenter.inverse_of
      assert_nil presenter.scoped?
      assert_nil presenter.options_dependent
      assert_nil presenter.options_class_name
      assert_nil presenter.options_autosave
      assert_nil presenter.options_required
      assert_nil presenter.options_other
    end

    def test_note_belongs_to_user
      # Setup
      note_user_association = Note.reflect_on_association(:user)
      presenter = ::Tuttle::Presenters::ActiveRecord::ReflectionPresenter.new(note_user_association, view)

      # Delegated methods
      assert_equal :user.inspect, presenter.name
      assert_equal :belongs_to.inspect, presenter.macro
      assert_nil presenter.type
      assert_equal "user_id", presenter.foreign_key

      # Presenter Methods
      assert_nil presenter.inverse_of
      assert_nil presenter.scoped?
      assert_nil presenter.options_dependent
      assert_nil presenter.options_class_name
      assert_nil presenter.options_autosave
      assert_nil presenter.options_required
      assert_nil presenter.options_other
    end

  end
end
