// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#00ff00"}, shadowColor: "rgba(0, 255, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Terminal functionality
class TerminalInterface {
  constructor() {
    this.commandHistory = []
    this.historyIndex = -1
    this.initializeTerminal()
    this.initializeKeyboardShortcuts()
  }

  initializeTerminal() {
    // Add terminal cursor blinking effect to focused inputs
    document.addEventListener('DOMContentLoaded', () => {
      const terminalInputs = document.querySelectorAll('.terminal-input')
      terminalInputs.forEach(input => {
        input.addEventListener('focus', (e) => {
          e.target.classList.add('terminal-cursor')
        })
        
        input.addEventListener('blur', (e) => {
          e.target.classList.remove('terminal-cursor')
        })
      })
    })

    // Add typing sound effect (optional - can be toggled)
    this.addTypingEffect()
  }

  initializeKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Ctrl+C to clear focused input
      if (e.ctrlKey && e.key === 'c') {
        const activeElement = document.activeElement
        if (activeElement.classList.contains('terminal-input')) {
          activeElement.value = ''
          e.preventDefault()
        }
      }

      // Ctrl+L to clear screen (scroll to top)
      if (e.ctrlKey && e.key === 'l') {
        window.scrollTo(0, 0)
        e.preventDefault()
      }

      // Arrow keys for command history (if in terminal input)
      if (document.activeElement.classList.contains('terminal-command-input')) {
        if (e.key === 'ArrowUp') {
          this.navigateHistory('up')
          e.preventDefault()
        } else if (e.key === 'ArrowDown') {
          this.navigateHistory('down')
          e.preventDefault()
        }
      }

      // Tab to focus on next terminal input
      if (e.key === 'Tab') {
        const terminalInputs = Array.from(document.querySelectorAll('.terminal-input'))
        const currentIndex = terminalInputs.indexOf(document.activeElement)
        if (currentIndex !== -1) {
          const nextIndex = (currentIndex + 1) % terminalInputs.length
          terminalInputs[nextIndex].focus()
          e.preventDefault()
        }
      }
    })
  }

  navigateHistory(direction) {
    if (this.commandHistory.length === 0) return

    if (direction === 'up') {
      this.historyIndex = Math.max(0, this.historyIndex - 1)
    } else if (direction === 'down') {
      this.historyIndex = Math.min(this.commandHistory.length - 1, this.historyIndex + 1)
    }

    const input = document.activeElement
    if (input && this.commandHistory[this.historyIndex]) {
      input.value = this.commandHistory[this.historyIndex]
    }
  }

  addCommand(command) {
    if (command.trim() && !this.commandHistory.includes(command)) {
      this.commandHistory.unshift(command)
      if (this.commandHistory.length > 50) {
        this.commandHistory = this.commandHistory.slice(0, 50)
      }
    }
    this.historyIndex = -1
  }

  addTypingEffect() {
    // Optional typing sound - can be enabled/disabled
    const playTypingSound = false // Set to true to enable typing sounds

    if (playTypingSound) {
      document.addEventListener('keypress', (e) => {
        if (document.activeElement.classList.contains('terminal-input')) {
          // Create a brief audio beep (you can replace with actual sound file)
          const audioContext = new (window.AudioContext || window.webkitAudioContext)()
          const oscillator = audioContext.createOscillator()
          const gainNode = audioContext.createGain()
          
          oscillator.connect(gainNode)
          gainNode.connect(audioContext.destination)
          
          oscillator.frequency.value = 800
          gainNode.gain.value = 0.1
          
          oscillator.start()
          oscillator.stop(audioContext.currentTime + 0.1)
        }
      })
    }
  }

  // Terminal command simulation
  executeTerminalCommand(command) {
    const commands = {
      'help': () => this.showHelp(),
      'clear': () => this.clearScreen(),
      'ls': () => this.listUrls(),
      'pwd': () => '/home/encurta',
      'whoami': () => 'encurta-user',
      'date': () => new Date().toLocaleString(),
      'uptime': () => 'System online - URL shortener active'
    }

    if (commands[command]) {
      return commands[command]()
    } else {
      return `Command not found: ${command}. Type 'help' for available commands.`
    }
  }

  showHelp() {
    return `Available commands:
  help      - Show this help message
  clear     - Clear the terminal screen  
  ls        - List all URLs
  shorten   - Create a new short URL
  pwd       - Show current directory
  whoami    - Show current user
  date      - Show current date/time
  uptime    - Show system status`
  }

  clearScreen() {
    const terminalContent = document.querySelector('.terminal-content')
    if (terminalContent) {
      terminalContent.innerHTML = ''
    }
    window.scrollTo(0, 0)
  }

  listUrls() {
    // This would typically make an API call or redirect
    window.location.href = '/urls'
  }
}

// Initialize terminal interface
const terminal = new TerminalInterface()

// Make it globally available for debugging
window.terminal = terminal

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

