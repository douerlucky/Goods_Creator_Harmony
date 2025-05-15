import { company, user } from './accout'
import { Updated_Badge } from './Badge'

interface orderlist_information {
  orderid:string
  user_info:user
  company_info:company
  badge_info:Updated_Badge
  quantity:number
  total_price:number
  status:number
  order_time:string
}

export {orderlist_information}