// Override gem: collections_utils interop may be { default: Class }; see collections_v2.es6.
// Gem constructor always ran `new CollectionUtilities()` before checking element.length, which
// aborted Hyrax.initialize on pages without `.collection-types-wrapper`.
import CollectionUtilitiesModule from 'hyrax/collections_utils';

const CollectionUtilities =
  CollectionUtilitiesModule && CollectionUtilitiesModule.default
    ? CollectionUtilitiesModule.default
    : CollectionUtilitiesModule;

export default class CollectionTypes {
  constructor(element) {
    if (element.length === 0) {
      return;
    }

    this.collectionUtilities = new CollectionUtilities();

    this.handleCollapseToggle();
    this.handleDelete();

    // Edit Collection Type
    this.setupAddParticipantsHandler();
    this.participantsAddButtonDisabler();
  }

  setupAddParticipantsHandler() {
    const { addParticipants } = this.collectionUtilities;
    const wrapEl = '.form-add-participants-wrapper';
    const url = '/admin/collection_type_participants?locale=en';

    $('#participants')
      .find('.add-participants-form input[type="submit"]')
      .on(
        'click',
        {
          wrapEl,
          urlFn: (e) => url,
        },
        addParticipants.handleAddParticipants.bind(addParticipants),
      );
  }

  handleCollapseToggle() {
    let $collapseHeader = $('a.collapse-header');
    let $collapseHeaderSpan = $('a.collapse-header').find('span');
    const collapseText = $collapseHeader.data('collapseText');
    const expandText = $collapseHeader.data('expandText');

    $('#collapseAbout').on('show.bs.collapse', () => {
      $collapseHeader.addClass('open');
      $collapseHeaderSpan.html(collapseText);
    });
    $('#collapseAbout').on('hide.bs.collapse', () => {
      $collapseHeader.removeClass('open');
      $collapseHeaderSpan.html(expandText);
    });
  }

  handleDelete() {
    $('.delete-collection-type').on('click', (event) => {
      let dataset = event.target.dataset;
      let collectionType = JSON.parse(dataset.collectionType) || null;
      let hasCollections = dataset.hasCollections === 'true';
      this.handleDelete_event_target = event.target;
      this.collectionType_id = collectionType.id;

      if (hasCollections === true) {
        $('.view-collections-of-this-type').attr('href', dataset.collectionTypeIndex);
        $('#deleteDenyModal').modal();
      } else {
        $('#deleteModal').modal();
      }
    });

    $('.confirm-delete-collection-type').on('click', (event) => {
      event.preventDefault();
      const deleteTarget = this.handleDelete_event_target;
      const collectionTypeId = this.collectionType_id;
      const $clicked = $(event.target);
      $.ajax({
        url: window.location.pathname + '/' + collectionTypeId,
        type: 'DELETE',
      }).done(() => {
        $(deleteTarget).parent('td').parent('tr').remove();
        let defaultButton = $clicked.parent('div').find('.btn-default');
        defaultButton.trigger('click');
      });
    });

    $('.view-collections-of-this-type').on('click', (event) => {
      $('#deleteDenyModal').modal('hide');
    });
  }

  participantsAddButtonDisabler() {
    const { addParticipantsInputValidator } = this.collectionUtilities;
    const buttonSelector = '.add-participants-form input[type="submit"]';
    const inputsWrapper = '.form-add-participants-wrapper';

    $('#participants')
      .find(inputsWrapper)
      .on(
        'change',
        {
          buttonSelector,
          inputsWrapper,
        },
        addParticipantsInputValidator.handleWrapperContentsChange.bind(addParticipantsInputValidator),
      );
  }
}
