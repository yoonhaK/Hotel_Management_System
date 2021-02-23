package com.cpsc304.HotelManagement.DBHandler;

import com.cpsc304.HotelManagement.Model.ReservationGuest;
import com.cpsc304.HotelManagement.Model.ReservationRequest;
import com.cpsc304.HotelManagement.Utils.DateFormatter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Component
public class ReservationRequestHandler {
    @Autowired
    JdbcTemplate jt;

    public Integer insertReservationRequest(ReservationRequest rr){
        // auto index
        String sql1 = "SELECT MAX(rid) FROM reservation_req";
        List<Map<String, Object>> ret = jt.queryForList(sql1);
        Integer rid = (Integer) ret.get(0).get("max");
        if (rid == null) {
            rid = 0;
        } else {
            rid = rid + 1;
        }
        String sql2 = "INSERT INTO reservation_req VALUES(?,?,?,?,?,?,?,?);";
        jt.update(sql2, rid, rr.getGuest_id(), rr.getM_date(), rr.getM_time(), rr.getReq_code(), rr.getReq_status(), rr.getDate(), rr.getRm_number());
        return rid;
    }

    public List<Map<String,Object>> findSuccessRequests(Integer gid) {
        String sql = "SELECT * FROM reservation_req WHERE guest_id = ? AND req_status = 1 ORDER BY date DESC, rm_number ;";
        List<Map<String, Object>> ret = jt.queryForList(sql,gid);
        return ret;
    }


    public List<Map<String,Object>> findSuccessRequests(String photoID, String creditCard) {
        String sql = "SELECT reservation_guest.guest_id, rid, m_date, m_time, req_code, req_status, date, rm_number  FROM reservation_req, reservation_guest WHERE photo_identity = ? AND  credit_card = ? AND req_status = 1 " +
                " AND reservation_req.guest_id = reservation_guest.guest_id ORDER BY date DESC, rm_number ;";
        List<Map<String, Object>> ret = jt.queryForList(sql,photoID, creditCard);
        return ret;
    }


    public void cancelReservation(Integer rid) {
        String sql1 = "DELETE FROM reservation_req WHERE rid = ?;";
        jt.update(sql1, rid);
    }

    public List<Map<String,Object>> getReservationGuest(Integer rid) {
        String sql = "SELECT g.guest_id, g.name FROM " +
                "reservation_req rq, guest g " +
                "WHERE rq.rid = ? AND g.guest_id = rq.guest_id";
        return jt.queryForList(sql, rid);
    }

    public boolean allReserved(Date start, Date end, Integer rm_number, Integer guest_id) {
        String sql = "SELECT * FROM reservation_req req WHERE req.date >= " +
                "date " + "'" + DateFormatter.dateToString(start) + "' " +
                " AND req.date <= " +
                "date " + "'" + DateFormatter.dateToString(end) + "' " +
                "AND req.rm_number = ? AND req.guest_id = ? AND req.req_status = 1;";
        List<Map<String, Object>> result = jt.queryForList(sql,rm_number, guest_id);
        //System.out.println(result);
        Integer diff = DateFormatter.getDateDifference(start, end);
        //System.out.println(diff);
        return (diff + 1 == result.size());
    }

    public List<Map<String, Object>> findReqByRoomAndDate(Integer rm_number, Date date) {
        String sql = "SELECT * FROM reservation_req req WHERE req.rm_number = ? AND req.date = ? AND req.req_status = 1;";
        List<Map<String, Object>> result = jt.queryForList(sql, rm_number, date);
        return  result;
    }

    public List<Map<String, Object>> getProjectionQuery(List<String> arr) {
        String sql = "SELECT DISTINCT " + produceStringProjection(arr) + " FROM reservation_req rr, guest g WHERE rr.guest_id = g.guest_id;";
        return jt.queryForList(sql);
    }

    public List<Map<String, Object>> getGuestsWithMoreReservations(Integer n) {
        String sql = "SELECT g.guest_id, g.name, g.phone From reservation_req rr, guest g WHERE rr.guest_id = g.guest_id GROUP BY g.guest_id, g.phone, g.name HAVING COUNT(*) >= ?";
        List<Map<String, Object>> re = jt.queryForList(sql, n);
        return  re;
    }

    public String produceStringProjection(List<String> arr) {
        StringBuilder init = new StringBuilder(arr.get(0));
        for (int i = 1; i < arr.size(); i++) {
            init.append(",").append(arr.get(i));
        }
        return init.toString();
    }
}
