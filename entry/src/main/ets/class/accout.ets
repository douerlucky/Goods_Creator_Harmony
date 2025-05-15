interface user{
  uid:string
  user_name:string
  pwd:string
  profile_url:string
  tel:string
  address:string
}

interface company{
  cid:string
  cname:string
  ctel:string
  caddress:string

}

export {user,company}