const userMixin = {
  data() {
    return {
      allUsers: []
    }
  },
  methods: {
    async getAllUsers() {
      const res = await this.$axios.get('/all_users/')
      this.allUsers = res.data.users
    },
  },
};
export default userMixin;
