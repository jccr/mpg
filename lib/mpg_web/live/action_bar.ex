defmodule ActionBar do
  use MpgWeb, :component

  def action_bar(assigns) do
    ~H"""
    <nav class="fixed left-0 bottom-0 w-full bg-gray-800 shadow-[0_0_40px_20px_rgba(0,0,0,0.3)]">
      <div class="container md:max-w-3xl mx-auto flex justify-center p-4 gap-4">
        <%= render_slot(@inner_block) %>
      </div>
    </nav>
    """
  end
end
