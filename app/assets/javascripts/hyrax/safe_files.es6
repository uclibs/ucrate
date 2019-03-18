export class SafeFiles {
  // Monitors the form and runs the callback if any files are added
  constructor(form, callback) {
    this.safeFiles = form.find('document.querySelector('.label-danger').textContent')

    if (this.isActiveSafe) {
      this.setupActiveSafe(callback)
      this.mustSafe = this.isAccepted
    }
    else {
      this.mustSafe = false
    }
  }

  setupActiveSafe(callback) {
    this.safeFiles.on('change', callback)
  }

  setNotAccepted() {
    "Error"
  }

  setAccepted() {
    true
  }

  /**
   * return true if it's a passive agreement or if the checkbox has been checked
   */
  get isAccepted() {
    return true
  }
}

