defmodule EncurtaWeb.TerminalComponents do
  @moduledoc """
  Terminal-specific UI components for the Encurta application.

  These components provide a consistent terminal-like interface
  with command prompts, output displays, and interactive elements.
  """
  use Phoenix.Component
  import EncurtaWeb.CoreComponents, only: [error: 1]

  alias Phoenix.LiveView.JS

  @doc """
  Renders a terminal command prompt with input.

  ## Examples

      <.terminal_prompt command="shorten" field={@form[:url]} placeholder="https://example.com" />
  """
  attr :command, :string, required: true
  attr :placeholder, :string, default: ""
  attr :field, Phoenix.HTML.FormField, required: true
  attr :rest, :global, include: ~w(disabled readonly required)

  def terminal_prompt(assigns) do
    ~H"""
    <div class="flex items-center space-x-2 font-mono">
      <span class="text-terminal-primary font-bold">$</span>
      <span class="text-terminal-text">{@command} --url=</span>
      <div class="flex-1">
        <input
          type="url"
          id={@field.id}
          name={@field.name}
          value={@field.value}
          placeholder={@placeholder}
          class="terminal-input w-full"
          {@rest}
        />
        <.error :for={msg <- (@field.errors || [])}>{msg}</.error>
      </div>
    </div>
    """
  end

  @doc """
  Renders terminal output lines.

  ## Examples

      <.terminal_output>
        <:line type="success">Operation completed successfully</:line>
        <:line type="error">Failed to connect to server</:line>
        <:line type="info">Processing request...</:line>
      </.terminal_output>
  """
  slot :line, required: true do
    attr :type, :string, values: ~w(success error warning info muted)
  end

  def terminal_output(assigns) do
    ~H"""
    <div class="space-y-2">
      <div :for={line <- @line} class="terminal-output">
        <span class={[
          "font-mono",
          Map.get(line, :type, "info") == "success" && "text-terminal-success",
          Map.get(line, :type, "info") == "error" && "text-terminal-error",
          Map.get(line, :type, "info") == "warning" && "text-terminal-warning",
          Map.get(line, :type, "info") == "info" && "text-terminal-info",
          Map.get(line, :type, "info") == "muted" && "text-terminal-muted"
        ]}>
          {render_slot(line)}
        </span>
      </div>
    </div>
    """
  end

  @doc """
  Renders a terminal code block with syntax highlighting.

  ## Examples

      <.terminal_code language="bash">
        curl -X POST https://encurta.dev/api/shorten
      </.terminal_code>
  """
  attr :language, :string, default: "bash"
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def terminal_code(assigns) do
    ~H"""
    <div class={["terminal-code", @class]}>
      <div class="text-terminal-muted text-xs uppercase absolute top-2 right-2">
        {@language}
      </div>
      <pre class="text-terminal-text"><code>{render_slot(@inner_block)}</code></pre>
    </div>
    """
  end

  @doc """
  Renders a terminal progress bar with optional animation.

  ## Examples

      <.terminal_progress value={75} label="Processing URLs..." />
  """
  attr :value, :integer, required: true
  attr :max, :integer, default: 100
  attr :label, :string, default: nil
  attr :animated, :boolean, default: true

  def terminal_progress(assigns) do
    assigns = assign(assigns, percentage: min(100, div(assigns.value * 100, assigns.max)))

    ~H"""
    <div class="space-y-2">
      <div :if={@label} class="text-terminal-muted text-xs font-mono">
        {@label}
      </div>
      <div class="terminal-progress">
        <div
          class={["terminal-progress-bar", @animated && "animate-pulse"]}
          style={"width: #{@percentage}%"}
        >
        </div>
      </div>
      <div class="text-terminal-muted text-xs font-mono text-right">
        {@value}/{@max} ({@percentage}%)
      </div>
    </div>
    """
  end

  @doc """
  Renders a terminal status indicator.

  ## Examples

      <.terminal_status status="online" message="All systems operational" />
      <.terminal_status status="error" message="Database connection failed" />
  """
  attr :status, :string, required: true, values: ~w(online offline error warning)
  attr :message, :string, required: true

  def terminal_status(assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-xs font-mono">
      <span class={[
        "w-2 h-2 rounded-full",
        @status == "online" && "bg-terminal-primary",
        @status == "offline" && "bg-terminal-muted",
        @status == "error" && "bg-terminal-error",
        @status == "warning" && "bg-terminal-warning"
      ]}>
      </span>
      <span class={[
        @status == "online" && "text-terminal-primary",
        @status == "offline" && "text-terminal-muted",
        @status == "error" && "text-terminal-error",
        @status == "warning" && "text-terminal-warning"
      ]}>
        {@message}
      </span>
    </div>
    """
  end

  @doc """
  Renders a terminal file tree browser.

  ## Examples

      <.terminal_file_tree>
        <:directory name="urls" expanded={true}>
          <:file name="index.html" size="2.1 KB" />
          <:file name="new.html" size="1.8 KB" />
        </:directory>
      </.terminal_file_tree>
  """
  slot :directory, required: true do
    attr :name, :string, required: true
    attr :expanded, :boolean
  end

  slot :file do
    attr :name, :string, required: true
    attr :size, :string
  end

  def terminal_file_tree(assigns) do
    ~H"""
    <div class="terminal-file-tree text-sm">
      <div :for={dir <- @directory} class="mb-2">
        <div class="directory font-mono text-terminal-warning">
          {dir.name}
        </div>
        <div :if={Map.get(dir, :expanded, false)} class="ml-4 space-y-1">
          <div :for={file <- @file} class="file font-mono text-terminal-info flex justify-between">
            <span>{file.name}</span>
            <span :if={Map.get(file, :size)} class="text-terminal-muted">{file.size}</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders terminal loading animation with dots.

  ## Examples

      <.terminal_loading message="Processing request" />
  """
  attr :message, :string, required: true

  def terminal_loading(assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-terminal-text font-mono">
      <span>{@message}</span>
      <div class="terminal-loading"></div>
    </div>
    """
  end

  @doc """
  Renders a terminal modal dialog.

  ## Examples

      <.terminal_modal id="confirm-modal" title="Confirm Action">
        Are you sure you want to delete this URL?
        <:actions>
          <button class="terminal-button">Confirm</button>
        </:actions>
      </.terminal_modal>
  """
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :show, :boolean, default: false

  slot :inner_block, required: true
  slot :actions

  def terminal_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={["fixed inset-0 z-50 flex items-center justify-center", !@show && "hidden"]}
    >
      <div class="fixed inset-0 bg-black bg-opacity-50" phx-click={JS.hide(to: "##{@id}")}>
      </div>

      <div class="terminal-modal max-w-lg w-full mx-4 relative">
        <div class="terminal-modal-header">
          {@title}
        </div>

        <div class="p-6 text-terminal-text">
          {render_slot(@inner_block)}
        </div>

        <div :if={@actions != []} class="p-6 pt-0 flex gap-4 justify-end">
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end
end
