defmodule ActionBar do
  use MpgWeb, :component

  def action_bar(assigns) do
    ~H"""
    <nav class="fixed left-0 bottom-0 w-full bg-[#18191c] shadow-[0_0_40px_20px_rgba(0,0,0,0.3)] text-2xl">
      <div class="container md:max-w-xl mx-auto flex flex-col md:flex-row justify-center px-6 py-[4vh] gap-4">
        <%= render_slot(@inner_block) %>
      </div>
    </nav>
    """
  end
end
