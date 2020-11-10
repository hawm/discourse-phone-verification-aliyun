import Component from "@ember/component";
import CanCheckEmails from "discourse/mixins/can-check-emails";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend(CanCheckEmails, {
  hasCheckPhone: false,
  @discourseComputed("canCheckEmails")
  canCheckPhone(canCheckEmails) {
    return canCheckEmails;
  },
  actions: {
    checkPhone(model) {
      model.checkPhone();
      this.set("hasCheckPhone", true)
    },
  },
});
