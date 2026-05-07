// Override gem: Almond/Babel may expose hyrax/collections_utils as { default: Class }.
// Using that object with `new` throws and aborts Hyrax.initialize(), which prevents later
// Blacklight.onLoad callbacks (notably hyrax/collections.js delete-modal handlers) from running.
import CollectionUtilitiesModule from 'hyrax/collections_utils';

const CollectionUtilities =
  CollectionUtilitiesModule && CollectionUtilitiesModule.default
    ? CollectionUtilitiesModule.default
    : CollectionUtilitiesModule;

export default class CollectionsV2 {
  constructor() {
    this.collectionUtilities = new CollectionUtilities();
    this.setupAddSharingHandler();
    this.sharingAddButtonDisabler();
  }

  /**
   * Set up the handler for adding groups or users via AJAX POSTS at the following location:
   * Collection > Edit > Sharing tab; or
   * Collection Types > Edit > Participants tab
   * @return {void}
   */
  setupAddSharingHandler() {
    const { addParticipants } = this.collectionUtilities;
    const wrapEl = '.form-add-sharing-wrapper';

    $('#participants')
      .find('.edit-collection-add-sharing-button')
      .on(
        'click',
        {
          wrapEl,
          urlFn: (e) => {
            const $wrapEl = $(e.target).parents(wrapEl);
            return '/dashboard/collections/' + $wrapEl.data('id') + '/permission_template?locale=en';
          },
        },
        addParticipants.handleAddParticipants.bind(addParticipants),
      );
  }

  /**
   * Set up enabling/disabling "Add" button for adding groups and/or users in
   * Edit Collection > Sharing tab
   * @return {void}
   */
  sharingAddButtonDisabler() {
    const { addParticipantsInputValidator } = this.collectionUtilities;
    const inputsWrapper = '.form-add-sharing-wrapper';

    $('#participants')
      .find(inputsWrapper)
      .on(
        'change',
        {
          buttonSelector: '.edit-collection-add-sharing-button',
          inputsWrapper,
        },
        addParticipantsInputValidator.handleWrapperContentsChange.bind(addParticipantsInputValidator),
      );
  }
}
