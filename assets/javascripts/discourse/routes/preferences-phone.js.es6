import RestrictedUserRoute from "discourse/routes/restricted-user";

export default RestrictedUserRoute.extend({
  model: function () {
    return this.modelFor("user");
  },

  renderTemplate: function () {
    this.render({ into: "user" });
  },

  setupController: function (controller, model) {
    controller.set("model", model)
    controller.loadPhone("")
  },
});
