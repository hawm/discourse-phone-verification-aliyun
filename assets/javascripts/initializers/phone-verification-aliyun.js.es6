import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";
import { userPath } from "discourse/lib/url";
import { ajax } from "discourse/lib/ajax";

function initializePhoneVerificationAliyun(api) {
  // https://github.com/discourse/discourse/blob/master/app/assets/javascripts/discourse/lib/plugin-api.js.es6
  api.modifyClass("model:user", {
    checkPhone(password){
      return ajax(userPath(`${this.username_lower}/preferences/phone-detail`), {
        data: { password },
        type: "POST"
      })
    },
    @discourseComputed("can_edit_email")
    can_edit_phone(can_edit_email){
      return can_edit_email
    }
  })
}

export default {
  name: "phone-verification-aliyun",

  initialize() {
    withPluginApi("0.8.31", initializePhoneVerificationAliyun);
  }
};