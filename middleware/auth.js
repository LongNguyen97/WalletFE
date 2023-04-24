export default function ({ $axios, redirect }) {
  $axios.onError((error) => {
    if (error.response && error.response.status === 401) {
      redirect('/login')
    }
  })
}
