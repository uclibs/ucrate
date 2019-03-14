// [scholar-override] Overriding preventSubmit to pick up our local virus component
import SaveWorkControl from 'hyrax/save_work/save_work_control'
import { RequiredFields } from 'hyrax/save_work/required_fields'
import { ChecklistItem } from 'hyrax/save_work/checklist_item'
import { UploadedFiles } from 'hyrax/save_work/uploaded_files'
import { DepositAgreement } from 'hyrax/save_work/deposit_agreement'
import VisibilityComponent from './visibility_component'

export default class ScholarSaveWorkControl extends SaveWorkControl {
    constructor(element, adminSetWidget) {
        super(element, adminSetWidget);
    }

   /**
   * Keep the form from being submitted if there is an error with uploader
   *
   */
 
   preventSubmitIfError() {
     this.form.on('submit', (evt) => {
      debugger;
      if (document.querySelector('.label-danger').textContent == 'Error') {
        this.saveButton.prop("disabled", true);
      }
    })
  }

  preventSubmit() {
    debugger;
    this.preventSubmitUnlessValid()
    this.preventSubmitIfAlreadyInProgress()
    this.preventSubmitIfUploading()
    this.preventSubmitIfError()
  }
};


