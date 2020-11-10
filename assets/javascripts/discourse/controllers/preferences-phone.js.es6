import I18n from "I18n";
import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import ajax from "discourse/lib/ajax";
import EmberObject from "@ember/object";
import { or } from "@ember/object/computed";
import { userPath } from "discourse/lib/url";

import phoneValid from "../lib/phone-valid";

export default Controller.extend({
    successMessage: null,
    errorMessage: null,

    loading: false,
    password: null,

    progress: null,

    oldPhone: null,

    phone: {
        prefix: null,
        number: null,
    },

    token: null,

    hasMessage: or(
        "successMessage",
        "errorMessage"
    ),

    @discourseComputed("phone")
    invalidPhone(phone){
        return !phoneValid(phone)
    },

    @discourseComputed("invalidPhone")
    phoneValidation(invalidPhone){
        if (invalidPhone){
            return EmberObject.create({
                failed: true,
                reason: I18n.t("phone_verification_aliyun.invalid_phone.title")
            })
        }

    },

    handleError(error) {
        if(error.jqXHR) {
            error = error.jqXHR
        }
        let parsedJSON = error.responseJSON;
        if (parsedJSON.error_type === "invalid_access"){
            DiscourseURL.redirectTo(
                userPath(`${this.model.username_lower}/preferences/phone`)
            )
        }else{
            popupAjaxError(error)
        }
    },

    loadPhone(password){
        this.set("loading", true)
        this.model.checkPhone(password)
        .then(resp => {
            if (resp.error){
                this.set("errorMessage", resp.error)
                return
            }
            this.setProperties({
                errorMessage: null, 
                oldPhone: resp.phone,
                password: null,
                progress: {continue: !resp.password_required}
            })
        })
        .catch( e => this.handleError(e))
        .finally( ()=> this.set("loading", false));
    },

    @discourseComputed("invalidPhone")
    requestToken(invalidPhone){
        if (invalidPhone){
            return
        }
        this.set("loading", true)
        ajax(userPath(`${this.model.username_lower}/preferences/phone`), {
            data: { phone },
            type: "POST"
        }).then( resp => {
            if (resp.error){
                this.set("errorMessage", resp.error)
                return
            }
            this.setProperties({
                successMessage: "Token has been send to your phone",
                errorMessage: null,
                progress: {confirmToken: true}

            })
        }).catch( e => {

        }).finally( () => {
            this.set("loading", false)
        })

    },

    confirmToken(){
        this.set("loading", true)
        ajax(userPath(`${this.model.username_lower}/preference/phone`), {
            data: [phone, token],
            type: "POST"
        }).then( resp => {
            if(resp.error){
                this.set("errorMessage", resp.error)
                return
            }
            this.setProperties({
                errorMessage: null,
                progress: {done: true}
            })
        })
    },


    actions:{
        confirmPassword(){
            if(!this.password){
                return
            }
            this.loadPhone(this.password)
        },
        continueAddOrChange(){
            this.set("progress", {requestToken: true})
            console.log(this.progress)
        },
        getToken(){
            this.requestToken()
        },
        confirmToken(){
            this.confirmToken()
        }

    }
});
